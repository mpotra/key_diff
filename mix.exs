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
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
