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
elixir --erl "+sbwt none" -S mix [eprof | eprof_total | fprof | cgrind | observer]
```
...or `eprof.sh`/`eprof_total.sh`/`fprof.sh`/`cgrind.sh` like this:
```
./scripts/eprof.sh [branch1 branch2 ... branchN]
``` 
so you can run a profiler against a set of branches (tag `v0.7.0` is included by default).
To open a result of `cgrind` task, you need an external tool, ie. `qcachegrind`.

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
