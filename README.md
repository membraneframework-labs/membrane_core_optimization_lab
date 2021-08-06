# Membrane Template Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_template_plugin.svg)](https://hex.pm/packages/membrane_template_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_template_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_template_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_template_plugin)

This repository contains a template for new elements.

Check out different branches for other flavours of template.

It is part of [Membrane Multimedia Framework](https://membraneframework.org).

## Installation

The package can be installed by adding `membrane_template_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_template_plugin, "~> 0.1.0"}
  ]
end
```

## Usage

via `run.exs`...
```
iex --erl "+sbwt none" -S mix run run.exs
```
...using mix tasks...
```
elixir --erl "+sbwt none" -S mix [eprof | fprof] [TIME_TO_RUN_IN_S=10]
elixir --erl "+sbwt none" -S mix observer
```
...or `exprof.sh`/`fprof.sh` like this:
```
scripts/exprof.sh [branch1 branch2 ... branchN]
``` 
so you can run a profiler against a set of branches (`master` is included by default).
By default a profiler will run for 10s for each branch. 
You can override this value by setting $TIME env variable.

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
