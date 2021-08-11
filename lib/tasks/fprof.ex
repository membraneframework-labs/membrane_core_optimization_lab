defmodule Mix.Tasks.Fprof do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.Tasks.Profile.Fprof.profile(
      fn -> OptimizationLab.Pipeline.run_for(10_000) end,
      warmup: false,
      callers: true,
      sort: :own
    )
  end
end
