defmodule Quill.MixProject do
  use Mix.Project

  def project do
    [
      app: :quill,
      version: "0.1.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Quill",
      description: description(),
      package: package(),
      source_url: "https://github.com/carash/quill",
      homepage_url: "https://github.com/carash/quill",
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end

  defp description() do
    "Simple Json logger backend for Elixir."
  end

  defp package() do
    [
      name: "quill",
      licenses: ["MIT"],
      files: ["lib/", "mix.exs", "README.md", "LICENSE"],
      links: %{"GitHub" => "https://github.com/carash/quill"}
    ]
  end
end
