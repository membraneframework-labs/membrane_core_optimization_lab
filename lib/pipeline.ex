defmodule OptimizationLab.Pipeline do
  use Membrane.Pipeline

  alias OptimizationLab.Source
  alias OptimizationLab.{Filter, Sink}
  # alias OptimizationLab.PushFilter, as: Filter
  # alias OptimizationLab.PushSink, as: Sink

  def run() do
    {:ok, pid} = start_link()
    play(pid)
  end

  @impl true
  def handle_init(_) do
    links = [
      link(:source, %Source{fps: 50})
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to({:filter, make_ref()}, Filter)
      |> to(:sink, Sink)
    ]

    {{:ok, spec: %ParentSpec{links: links}}, %{}}
  end
end
