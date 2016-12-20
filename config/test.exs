use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_pusher_lite, ExPusherLite.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ex_pusher_lite, ExPusherLite.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_pusher_lite_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :guardian, Guardian,
  secret_key: "F9zrIZZYAfvm32vCd3BWy2fISM7e5V9ZzPq40oBNPNcNhcFx3foREmMb8Jrbtmkx"
