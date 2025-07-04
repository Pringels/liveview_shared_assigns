defmodule SharedAssigns.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/your-org/shared_assigns"

  def project do
    [
      app: :shared_assigns,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "SharedAssigns",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix, "~> 1.7"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  defp description do
    """
    A React Context-like library for Phoenix LiveView that eliminates prop drilling
    by allowing components to subscribe to specific context values and automatically
    re-render when those contexts change.
    """
  end

  defp package do
    [
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "SharedAssigns",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
