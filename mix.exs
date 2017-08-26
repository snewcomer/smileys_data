defmodule SmileysData.Mixfile do
  use Mix.Project

  def project do
    [app: :smileysdata,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:phoenix_ecto, "~> 3.0"},
     {:kerosene, "~> 0.5.0"},
     {:coherence, "~> 0.5.0"},
     {:hashids, "~> 2.0"},
     {:hackney, "~> 1.9", override: true},
     {:marco_polo, git: "https://github.com/MyMedsAndMe/marco_polo.git"},
     {:decimal, "~> 1.2", override: true}]
  end
end