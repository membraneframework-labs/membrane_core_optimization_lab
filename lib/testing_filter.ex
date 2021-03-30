defmodule Membrane.OptimizationLab.TestingFilter do
  use Membrane.Filter

  def_options time_per_buffer: [
                spec: non_neg_integer(),
                default: 5,
                description: """
                Time that filter will spend on processing each buffer.
                This option allows to control processing speed of the filter.
                """
              ]

  def_output_pad :output, caps: :any

  def_input_pad :input, caps: :any, demand_unit: :buffers

  defmodule State do
    defstruct [
      :time_per_buffer
    ]
  end

  @impl true
  def handle_init(options), do: {:ok, Map.merge(%State{}, Map.from_struct(options))}

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {:ok, state}
  end

  @impl true
  def handle_demand(:output, size, :buffers, ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    %State{time_per_buffer: time_per_buffer} = state

    Process.sleep(time_per_buffer)

    {{:ok, buffer: {:output, buffer}, redemand: :output}, state}
  end
end
