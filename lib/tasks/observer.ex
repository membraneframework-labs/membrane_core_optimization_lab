defmodule Mix.Tasks.Observer do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.Task.run("compile")

    :observer.start()

    OptimizationLab.Pipeline.run()

    Process.sleep(:infinity)
  end
end
