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
    IO.inspect("Starting")
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
