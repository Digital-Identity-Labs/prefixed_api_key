defmodule PrefixedApiKey.MixProject do
  use Mix.Project

  def project do
    [
      app: :prefixed_api_key,
      version: "0.2.2",
      elixir: "~> 1.11",
      description: "Elixir module for generating a simple Prefixed API Key",
      package: package(),
      name: "PrefixedApiKey",
      source_url: "https://github.com/Digital-Identity-Labs/prefixed_api_key",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [
        tool: ExCoveralls
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:puid, "~> 2.3"},
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Digital-Identity-Labs/prefixed_api_key"
      }
    ]
  end

end
