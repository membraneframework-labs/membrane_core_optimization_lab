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
    {:ok, %{message_count: 0}}
  end

  @impl true
  def handle_info(:tick, state) do
    IO.inspect(state.message_count / 20)
    {:noreply, %{message_count: 0}}
  end

  @impl true
  def handle_cast(message, state) do
    if state.message_count == 0 do
      Process.send_after(self(), :tick, 20_000)
    end

    {:noreply, Map.update!(state, :message_count, &(&1 + 1))}
  end
end

defmodule BareGenServer.Source do
  use GenServer

  @message :crypto.strong_rand_bytes(1000)

  def start_link(send_to) do
    GenServer.start_link(__MODULE__, send_to)
  end

  @impl true
  def init(send_to) do
    {:ok, %{send_to: send_to}}
  end

  @impl true
  def handle_cast(:start, state) do
    GenServer.cast(state.send_to, @message)
    GenServer.cast(self(), :next_message)
    {:noreply, Map.put(state, :started, true)}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:noreply, %{state | started: false}}
  end

  @impl true
  def handle_cast(:next_message, %{started: true} = state) do
    GenServer.cast(state.send_to, @message)
    GenServer.cast(self(), :next_message)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:next_message, state) do
    {:noreply, state}
  end
end

n = 5

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
