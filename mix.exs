defmodule Renode.Mixfile do
  use Mix.Project

  def project do
    [app: :renode,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Renode, []}]
  end

  defp deps do
    [{:meck, "~> 0.8", only: :test}]
  end
end
