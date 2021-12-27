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
