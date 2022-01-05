defmodule MembranePipeline.Sink do
  use Membrane.Sink

  def_input_pad :input,
    caps: :any,
    mode: :push

  @impl true
  def handle_init(_opts) do
    {:ok, %{message_count: 0, start_time: 0}}
  end

  @impl true
  def handle_write(:input, _buffer, _context, state) do
    state =
      if state.message_count == 0 do
        Process.send_after(self(), :tick, 10_000)
        %{state | start_time: Membrane.Time.monotonic_time()}
      else
        state
      end

    {:ok, Map.update!(state, :message_count, &(&1 + 1))}
  end

  @impl true
  def handle_other(:tick, _ctx, state) do
    elapsed = (Membrane.Time.monotonic_time() - state.start_time) / Membrane.Time.second()

    IO.inspect(
      "Mailbox: #{Process.info(self())[:message_queue_len]} Elapsed: #{elapsed} [s] Messages: #{state.message_count / elapsed} [M/s]"
    )

    {:ok, %{state | message_count: 0}}
  end
end

defmodule MembranePipeline.Filter do
  use Membrane.Filter

  def_input_pad :input, caps: :any, mode: :push
  def_output_pad :output, caps: :any, mode: :push

  @impl true
  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {{:ok, caps: :any}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    {{:ok, [buffer: {:output, [buffer]}]}, state}
  end
end

# number of elements in the pipeline
n = 30

defmodule MembranePipeline.Source do
  use Membrane.Source

  alias Membrane.Buffer

  @message :crypto.strong_rand_bytes(1000)

  @interval 10

  # n = 3
  @messages_per_second 170_000
  # n = 4
  @messages_per_second 110_000
  # n = 5
  @messages_per_second 95_000
  # n = 6
  @messages_per_second 90_000
  # n = 7
  @messages_per_second 80_000
  # n = 8
  @messages_per_second 75_000
  # n = 9
  @messages_per_second 75_000
  # n = 10
  @messages_per_second 60_000
  # n = 15
  @messages_per_second 45_000
  # n = 20
  @messages_per_second 40_000
  # n = 25
  @messages_per_second 25_000
  # n = 30
  @messages_per_second 25_000

  def_output_pad :output, mode: :push, caps: :any

  @impl true
  def handle_init(_opts) do
    messages = (@messages_per_second * @interval / 1000) |> trunc()
    {:ok, %{messages: messages}}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    Process.send_after(self(), :next_buffer, @interval)
    {:ok, state}
  end

  @impl true
  def handle_other(:next_buffer, _ctx, state) do
    buffers = for _i <- 1..state.messages, do: %Buffer{payload: @message}
    actions = [buffer: {:output, buffers}]
    Process.send_after(self(), :next_buffer, @interval)
    {{:ok, actions}, state}
  end
end

require Membrane.RemoteControlled.Pipeline

alias Membrane.RemoteControlled.Pipeline
alias Membrane.ParentSpec

children = %{
  source: MembranePipeline.Source,
  sink: MembranePipeline.Sink
}

children =
  1..(n - 2)
  |> Enum.reduce(children, fn i, children_acc ->
    Map.put(children_acc, String.to_atom("filter#{i}"), MembranePipeline.Filter)
  end)

links = [
  1..(n - 2)
  |> Enum.reduce(ParentSpec.link(:source), fn i, link_acc ->
    ParentSpec.to(link_acc, String.to_atom("filter#{i}"))
  end)
  |> ParentSpec.to(:sink)
]

actions = [{:spec, %ParentSpec{children: children, links: links}}]

{:ok, pipeline} = Pipeline.start_link()
Pipeline.exec_actions(pipeline, actions)
Pipeline.play(pipeline)

Pipeline.await(:stop)
