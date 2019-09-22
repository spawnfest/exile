defmodule Exile.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      name: "Exile",
      source_url: "https://github.com/spawnfest/doodler",
      homepage_url: "https://exile-web.gigalixirapp.com",
      docs: docs()
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21.2", only: [:dev], runtime: false}
    ]
  end

  defp releases do
    [
      exile: [
        applications: [
          exile: :permanent,
          exile_web: :permanent
        ],
        version: "0.1.0"
      ]
    ]
  end

  defp docs do
    [
      logo: "priv/static/exile.svg",
      extras: ["README.md"]
    ]
  end
end
