eflame = :eflame.start(self())
OptimizationLab.Pipeline.run()
Process.sleep(30_000)
:eflame.stop(eflame)
