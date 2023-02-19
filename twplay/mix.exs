defmodule Twplay.MixProject do
  use Mix.Project

  @app :twplay

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [main_module: Twplay.CLI, emu_args: ["-sname #{@app}"]]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :iex, :inets],
      mod: {Twplay.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mpv_json_ipc, "~> 0.1.0"},
      {:amqp, "~> 3.2"},
      {:optimus, "~> 0.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
