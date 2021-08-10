defmodule Mix.Tasks.Cgrind do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    :fprof.apply(OptimizationLab.Pipeline, :run_for, [10_000])
    :fprof.profile()
    # :fprof.analyse({:dest, 'out.fprof'})
  end
end
