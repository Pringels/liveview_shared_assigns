import Config

config :demo, DemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "test_secret_key_base_change_me_in_production_very_long_string_at_least_64_chars",
  # Enable server for Wallaby tests
  server: true

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

# Configure Wallaby
config :wallaby,
  otp_app: :demo,
  driver: Wallaby.Chrome,
  base_url: "http://localhost:4002",
  # Hide browser window by default (set to false to see browser during development)
  headless: true,
  # Screenshot on failure
  screenshot_on_failure: true
