import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :messengyr, Messengyr.Repo,
  username: "postgres",
  password: "postgres",
  database: "messengyr_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :messengyr, MessengyrWeb.Endpoint,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      "test-only-insecure-secret-key-base-must-set-SECRET_KEY_BASE-env-var",
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

config :messengyr, Messengyr.Auth.Guardian,
  issuer: "messengyr",
  ttl: {30, :days},
  allowed_drift: 2000,
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "dev-only-insecure-key-do-not-use-in-prod"
