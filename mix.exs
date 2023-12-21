defmodule KeyDiff.MixProject do
  use Mix.Project

  @source_url "https://github.com/mpotra/key_diff"
  @version "0.1.0"

  def project do
    [
      app: :key_diff,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "",
      package: package(),

      # Docs
      name: "KeyDiff",
      docs: docs()
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
      # Development only deps
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},

      # Benchmarking
      {:map_diff, "~> 1.3", only: :dev},
      {:json_diff, "~> 0.1", only: :dev},
      {:json_diff_ex, "~> 0.6", only: :dev},
      {:jason, "~> 1.4"},
      {:benchee, "~> 1.2", only: :dev},

      # Docs deps only
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Mihai Potra"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(.formatter.exs mix.exs README.md LICENSE lib)
    ]
  end

  defp docs do
    [
      main: "KeyDiff",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: []
    ]
  end
end
