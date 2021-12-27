defmodule BareGenServer.Sink do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_init) do
    {:ok, %{message_count: 0, measurement_count: 0, avg: 0}}
  end

  @impl true
  def handle_info(:tick, state) do
    state = %{
      state
      | message_count: 0,
        measurement_count: state.measurement_count + 1,
        avg:
          (state.measurement_count * state.avg + state.message_count) /
            (state.measurement_count + 1)
    }

    IO.inspect(state.avg)
    {:noreply, state}
  end

  @impl true
  def handle_cast(message, state) do
    if state.message_count == 0 do
      Process.send_after(self(), :tick, 1000)
    end

    {:noreply, %{state | message_count: state.message_count + 1}}
  end
end
