import Config

# config :membrane_core, :logger, level: :critical

config :logger,
  compile_time_purge_matching: [
    [application: :membrane_core],
    [level_lower_than: :error]
  ]

# config :membrane_timescaledb_reporter, Membrane.Telemetry.TimescaleDB.Repo,
#   database: "membrane_timescaledb_reporter",
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   chunk_time_interval: "3 second",
#   chunk_compress_policy_interval: "1 second"

# config :membrane_timescaledb_reporter, ecto_repos: [Membrane.Telemetry.TimescaleDB.Repo]
