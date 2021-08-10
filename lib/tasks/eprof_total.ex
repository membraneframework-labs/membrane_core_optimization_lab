defmodule Mix.Tasks.EprofTotal do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    {:ok, p} = :eprof.start()
    :eprof.start_profiling(:erlang.processes() -- [p])
    OptimizationLab.Pipeline.run_for(10_000)
    :eprof.stop_profiling()
    :eprof.analyze(:total)
  end
end
