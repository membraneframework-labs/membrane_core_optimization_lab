# :observer.start()

Enum.each(1..20, fn _ ->
  OptimizationLab.Pipeline.run()
end)

# Process.sleep(:infinity)
