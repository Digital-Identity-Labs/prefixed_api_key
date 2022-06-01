defmodule PrefixedApiKey.MixProject do
  use Mix.Project

  def project do
    [
      app: :prefixed_api_key,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:puid, "~> 1.1"},
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test},
      {:benchee, "~> 1.0.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:earmark, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.17.0", only: :dev, runtime: false}
    ]
  end
end
