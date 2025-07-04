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
  plug(Phoenix.LiveView.Flash)

  def config(which)
  def config(:live_view), do: [signing_salt: "test_salt"]
  def config(_), do: nil

  defoverridable config: 1
end

# Start the test endpoint
{:ok, _} = SharedAssigns.TestEndpoint.start_link()
