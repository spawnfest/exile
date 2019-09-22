defmodule Exile.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
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
end
