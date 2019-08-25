defmodule EpubCoverExtractor.MixProject do
  use Mix.Project

  def project do
    [
      app: :epub_cover_extractor,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
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
      {:sweet_xml, git: "https://github.com/kbrw/sweet_xml"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A tool for get the ebooks covers"
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Constantin Guidon"],
      links: %{"GitHub" => "https://github.com/zelazna/epub_cover_extractor"}
    }
  end
end
