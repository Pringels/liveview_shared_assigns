ExUnit.start()

# Configure ExUnit for async testing
ExUnit.configure(exclude: [:skip], formatters: [ExUnit.CLIFormatter])

# Define a minimal endpoint for testing
defmodule SharedAssigns.TestEndpoint do
  use Phoenix.Endpoint, otp_app: :shared_assigns

  @session_options [
    store: :cookie,
    key: "_shared_assigns_test",
    signing_salt: "test_salt"
  ]

  plug(Plug.Session, @session_options)
end

# Configure the app for testing
Application.put_env(:shared_assigns, SharedAssigns.TestEndpoint,
  http: [port: 4001],
  secret_key_base: String.duplicate("a", 64),
  live_view: [
    signing_salt: "very_secret_salt_for_testing_only_12345678"
  ]
)

# Start the test endpoint
{:ok, _} = SharedAssigns.TestEndpoint.start_link()
