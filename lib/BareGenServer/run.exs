defmodule BareGenServer.Filter do
  use GenServer

  def start_link(send_to) do
    GenServer.start_link(__MODULE__, send_to)
  end

  @impl true
  def init(send_to) do
    {:ok, %{send_to: send_to}}
  end

  @impl true
  def handle_cast(message, state) do
    GenServer.cast(state.send_to, message)

    {:noreply, state}
  end
end

defmodule BareGenServer.Sink do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_init) do
    {:ok, %{message_count: 0, start_time: 0}}
  end

  @impl true
  def handle_info(:tick, state) do
    elapsed = (Membrane.Time.monotonic_time() - state.start_time) / Membrane.Time.second()

    IO.inspect(
      "Mailbox: #{Process.info(self())[:message_queue_len]} Elapsed: #{elapsed} [s] Throughput: #{state.message_count / elapsed} [kB/s]"
    )

    {:noreply, %{state | message_count: 0}}
  end

  @impl true
  def handle_cast(_message, state) do
    state =
      if state.message_count == 0 do
        Process.send_after(self(), :tick, 10_000)
        %{state | start_time: Membrane.Time.monotonic_time()}
      else
        state
      end

    {:noreply, Map.update!(state, :message_count, &(&1 + 1))}
  end
end

# number of elements in the pipeline
n = 30

defmodule BareGenServer.Source do
  use GenServer

  alias Membrane.Buffer

  @interval 10

  # n <= 4
  @messages_per_second 1_500_000
  # n <= 5
  @messages_per_second 1_200_000
  # n <= 8
  @messages_per_second 1_000_000
  # n <= 9
  @messages_per_second 800_000
  # n == 10
  @messages_per_second 700_000
  # n == 15
  @messages_per_second 500_000
  # n == 20
  @messages_per_second 400_000
  # n == 25
  @messages_per_second 300_000
  # n == 30
  @messages_per_second 250_000

  @message :crypto.strong_rand_bytes(1000)

  def start_link(send_to) do
    GenServer.start_link(__MODULE__, send_to)
  end

  @impl true
  def init(send_to) do
    messages = (@messages_per_second * @interval / 1000) |> trunc()
    {:ok, %{send_to: send_to, messages: messages}}
  end

  @impl true
  def handle_cast(:start, state) do
    send(self(), :next_message)
    {:noreply, Map.put(state, :started, true)}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:noreply, %{state | started: false}}
  end

  @impl true
  def handle_info(:next_message, %{started: true} = state) do
    Process.send_after(self(), :next_message, @interval)

    1..state.messages
    |> Enum.each(fn _i ->
      GenServer.cast(state.send_to, %Buffer{payload: @message})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info(:next_message, state) do
    {:noreply, state}
  end
end

{:ok, sink} = BareGenServer.Sink.start_link()

first_filter =
  1..(n - 2)
  |> Enum.reduce(sink, fn _i, pid ->
    {:ok, filter} = BareGenServer.Filter.start_link(pid)
    filter
  end)

{:ok, source} = BareGenServer.Source.start_link(first_filter)

GenServer.cast(source, :start)

receive do
  {:message_type, value} ->
    value
end
