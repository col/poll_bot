defmodule PollBot.Mixfile do
  use Mix.Project

  def project do
    [app: :poll_bot,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :nadia, :telegram, :inflex, :edeliver],
      mod: {PollBot, []}
    ]
  end

  defp deps do
    [
      {:nadia, git: "https://github.com/col/nadia"},
      {:telegram, "~> 0.0.3"},
      {:espec, "~> 0.8.18", only: :test},
      {:inflex, "~> 1.5.0"},
      {:edeliver, ">= 1.2.5"}
    ]
  end
end
