defmodule Greeklix.MixProject do
  use Mix.Project

  def project do
    [
      app: :greeklix,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Greeklix",
      source_url: "https://github.com/waseigo/greeklix",
      homepage_url: "https://blog.waseigo.com/tags/greeklix/",
      docs: [
        # The main page in the docs
        main: "Greeklix",
        logo: "./assets/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  defp description do
    """
    An Elixir library for converting Greek to Greeklish text.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Isaak Tsalicoglou"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/waseigo/greeklix"}
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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:unidecode, "~> 1.0"}
    ]
  end
end
