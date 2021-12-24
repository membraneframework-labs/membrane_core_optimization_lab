defmodule OptimizationLab.Source do
  use Membrane.Source

  def_output_pad :output, mode: :push, caps: :any

  def_options fps: [default: 1], size: [default: 1400]

  @impl true
  def handle_init(opts) do
    {:ok, Map.from_struct(opts)}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    use Ratio
    interval = 10 * Membrane.Time.second() / state.fps
    {{:ok, start_timer: {:timer, interval}}, state}
    # Process.send_after(
    #   self(),
    #   :tick,
    #   div(10 * Membrane.Time.second(), state.fps) |> Membrane.Time.to_milliseconds()
    # )

    # {:ok, state}
  end

  @impl true
  def handle_tick(:timer, _ctx, state) do
    # buffer = %Membrane.Buffer{payload: :crypto.strong_rand_bytes(state.size)}
    # {{:ok, buffer: {:output, buffer}}, state}
    Enum.each(1..10, fn _i -> send(self(), :tick) end)
    # Enum.each(1..10, fn _i -> GroupServer.send(self(), :tick) end)
    {:ok, state}
  end

  @impl true
  def handle_other(:tick, _ctx, state) do
    # IO.inspect(:tick)
    buffer = %Membrane.Buffer{payload: :crypto.strong_rand_bytes(state.size)}
    {{:ok, buffer: {:output, buffer}}, state}
  end

  # @impl true
  # def handle_other(:tick, _ctx, state) do
  #   # IO.inspect(:tick)

  #   Process.send_after(
  #     self(),
  #     :tick,
  #     div(Membrane.Time.second(), state.fps) |> Membrane.Time.to_milliseconds()
  #   )

  #   {:ok, state}
  # end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    {{:ok, stop_timer: :timer}, state}
  end
end
