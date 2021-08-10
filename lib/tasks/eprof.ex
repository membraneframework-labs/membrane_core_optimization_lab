defmodule Mix.Tasks.Eprof do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.Tasks.Profile.Eprof.profile(
      fn -> OptimizationLab.Pipeline.run_for(10_000) end,
      warmup: false,
      callers: true,
      sort: :time
    )
  end
end
