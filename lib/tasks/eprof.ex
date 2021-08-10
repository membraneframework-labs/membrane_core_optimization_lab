defmodule Mix.Tasks.Eprof do
  use Mix.Task

  defmacro profile(do: block) do
    content =
      quote do
        Mix.Tasks.Profile.Eprof.profile(
          fn -> unquote(block) end,
          warmup: false,
          callers: true,
          sort: :time
        )
      end

    Code.compile_quoted(content)
  end

  @impl Mix.Task
  def run(_) do
    profile do
      OptimizationLab.Pipeline.run_for(10_000)
    end
  end
end
