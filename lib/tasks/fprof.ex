defmodule Mix.Tasks.Fprof do
  use Mix.Task

  @impl Mix.Task
  def run(opts) do
    time = parse_opts(opts)

    Mix.Tasks.Profile.Fprof.profile(fn ->
      OptimizationLab.Pipeline.run()
      Process.sleep(time)
    end)
  end

  defp parse_opts(opts) do
    case opts do
      [time | _] -> String.to_integer(time) * 1_000
      _ -> 10_000
    end
  end
end
