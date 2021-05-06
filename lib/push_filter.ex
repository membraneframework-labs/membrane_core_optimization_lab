defmodule OptimizationLab.PushFilter do
  use Membrane.Filter

  def_options time_per_buffer: [
                spec: non_neg_integer(),
                default: 5,
                description: """
                Time that filter will spend on processing each buffer.
                This option allows to control processing speed of the filter.
                """
              ]

  def_output_pad :output, mode: :push, caps: :any

  def_input_pad :input, caps: :any, mode: :push

  @impl true
  def handle_init(options), do: {:ok, Map.from_struct(options)}

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {:ok, state}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    # payload = :crypto.strong_rand_bytes(byte_size(buffer.payload))
    # buffer = %Membrane.Buffer{buffer | payload: payload}
    {{:ok, buffer: {:output, buffer}}, state}
  end
end
