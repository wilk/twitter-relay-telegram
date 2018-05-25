defmodule TweetRelay.MixProject do
  use Mix.Project

  def project do
    [
      app: :tweetrelay,
      version: "0.1.0",
      elixir: "~> 1.6",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # this will call TweetRelay.start/2 function, because GenServer implements the Application module
      mod: {TweetRelay, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:extwitter, "~> 0.9.2"},
      {:nadia, "~> 0.4.3"}
    ]
  end
end
