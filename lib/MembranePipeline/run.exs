defmodule MembranePipeline.Sink do
  use Membrane.Sink

  def_input_pad :input,
    caps: :any,
    demand_unit: :buffers

  @impl true
  def handle_init(_opts) do
    {:ok, %{message_count: 0, measurement_count: 0, avg: 0}}
  end

  @impl true
  def handle_prepared_to_playing(_context, state) do
    {{:ok, demand: :input}, state}
  end

  @impl true
  def handle_write(:input, _buffer, _context, state) do
    if state.message_count == 0 do
      Process.send_after(self(), :tick, 1000)
    end

    {{:ok, demand: :input}, %{state | message_count: state.message_count + 1}}
  end

  @impl true
  def handle_other(:tick, _ctx, state) do
    state = %{
      state
      | message_count: 0,
        measurement_count: state.measurement_count + 1,
        avg:
          (state.measurement_count * state.avg + state.message_count) /
            (state.measurement_count + 1)
    }

    IO.inspect(state.avg)
    {:ok, state}
  end
end

defmodule MembranePipeline.Filter do
  use Membrane.Filter

  def_input_pad :input, demand_unit: :buffers, caps: :any
  def_output_pad :output, caps: :any

  @impl true
  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {{:ok, caps: :any}, state}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    {{:ok, [buffer: {:output, [buffer]}, redemand: :output]}, state}
  end
end

defmodule MembranePipeline.Source do
  use Membrane.Source

  alias Membrane.Buffer

  @message :crypto.strong_rand_bytes(1000)

  def_output_pad :output, caps: :any

  @impl true
  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    buffers = 1..size |> Enum.map(fn _i -> %Buffer{payload: @message} end)
    actions = [buffer: {:output, buffers}]
    {{:ok, actions}, state}
  end
end

require Membrane.RemoteControlled.Pipeline

alias Membrane.RemoteControlled.Pipeline
alias Membrane.ParentSpec

n = 30

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

Pipeline.await(:xd)
