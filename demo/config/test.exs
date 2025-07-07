import Config

config :demo, DemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "test_secret_key_base_change_me_in_production_very_long_string_at_least_64_chars",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
