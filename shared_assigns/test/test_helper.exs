ExUnit.start()

# Configure ExUnit for async testing
ExUnit.configure(exclude: [:skip], formatters: [ExUnit.CLIFormatter])
