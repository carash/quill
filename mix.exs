defmodule Quill.MixProject do
  use Mix.Project

  @source_url "https://github.com/carash/quill"
  @version "0.2.2"

  def project do
    [
      app: :quill,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      name: "Quill",
      homepage_url: @source_url,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:logfmt, "~> 3.3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Simple JSON logger backend for Elixir."
  end

  defp package() do
    [
      name: "quill",
      licenses: ["MIT"],
      files: ["lib/", "mix.exs", "README.md", "LICENSE"],
      links: %{"GitHub" => "https://github.com/carash/quill"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
