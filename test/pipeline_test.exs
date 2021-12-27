defmodule Membrane.OptimizationLab.PipelineTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  alias Membrane.OptimizationLab.TestingFilter
  alias Membrane.Testing
  alias Membrane.Buffer

  defmodule TestPipeline do
    use Membrane.Pipeline

    @buffer_size 10

    @impl true
    def handle_init(_options) do
      generator_function = fn state, size ->
        buffers = for n <- 1..size, do: %Buffer{payload: state + n}

        actions = [buffer: {:output, buffers}, redemand: :output]

        {actions, state + size}
      end

      spec = %ParentSpec{
        children: [
          sink: %Testing.Sink{},
          source: %Testing.Source{output: {0, generator_function}},
          fast_filter: %TestingFilter{time_per_buffer: 20},
          slow_filter: %TestingFilter{time_per_buffer: 10}
        ],
        links: [
          link(:source)
          |> to(:slow_filter)
          |> to(:fast_filter)
          |> to(:sink)
        ]
      }

      {{:ok, spec: spec}, %{}}
    end

    @impl true
    def handle_notification(_notification, _child, _ctx, state) do
      {:ok, state}
    end
  end

  test "run pipeline" do
    {:ok, pipeline} =
      %Testing.Pipeline.Options{module: TestPipeline} |> Testing.Pipeline.start_link()

    Testing.Pipeline.play(pipeline)
    assert_pipeline_playback_changed(pipeline, _, :playing)

    assert_start_of_stream(pipeline, :sink)

    Process.sleep(30_000)

    Testing.Pipeline.stop(pipeline)
    assert_pipeline_playback_changed(pipeline, _, :stopped)
  end
end
