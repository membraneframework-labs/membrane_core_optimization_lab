defmodule OptimizationLab.PushSink do
  use Membrane.Sink

  def_input_pad :input, mode: :push, caps: :any

  @impl true
  def handle_init(_opts) do
    {:ok, %{buffers: 0}}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {{:ok, start_timer: {:timer, Membrane.Time.second()}}, state}
    # {:ok, state}
  end

  @impl true
  def handle_tick(:timer, _ctx, state) do
    if state.init_time do
      time_delta = Membrane.Time.to_seconds(Membrane.Time.monotonic_time() - state.init_time)
      if time_delta > 0, do: IO.puts(round(state.buffers / time_delta))
    end

    {:ok, state}
  end

  @impl true
  def handle_write(:input, _buffer, _ctx, state) do
    state = Map.put_new_lazy(state, :init_time, fn -> Membrane.Time.monotonic_time() end)
    state = Map.update!(state, :buffers, &(&1 + 1))
    {:ok, state}
  end
end
