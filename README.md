# Tweetrelay
This is an application implemented by myself to learn and understand Elixir.
It's meant to be used as a tutorial for beginners.
Feel free to improve source code and docs.

## Setup
First, rename `.env.default` in `.env`:

```bash
$ mv .env.default .env
```

Then, replace the default vars with your credentials (Twitter and Telegram)

## Running
Just use `docker-compose` to run it:

```bash
$ docker-compose up
```

## Tutorial
Firstly, I've used `mix` to setup the project structure:

```bash
$ mix new tweetrelay
```

[mix](https://hexdocs.pm/mix/Mix.html) is the official build tool of Elixir.
With `mix new` you're able to create a new Elixir app scaffolder.

Then, I've configured the application using the `config/config.exs` file, that is used from the main application to load specific configurations.
Inside I've used `System.get_env()` function to retrieve the environment variables from the `.env` file:

```elixir
config :extwitter, :oauth, [
   consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
   consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
   access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
   access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
]
```

Those configurations are used to configure the [ExTwitter](https://github.com/parroty/extwitter) library, used to search tweets inside Twitter's network.

```elixir
config :nadia, token: System.get_env("TELEGRAM_BOT_TOKEN")
```

While this configuration is used to configure [Nadia](https://github.com/zhyu/nadia), a library for interacting with Telegram's API.

### Adding dependencies
It's time to add some dependencies to the project, exactly those expressed above.
It can be done by adding the following list to the `deps` method of the `MixProject` located inside `mix.exs` file:

```elixir
[
  {:extwitter, "~> 0.9.2"},
  {:nadia, "~> 0.4.3"}
]
```

`mix` can be used to install the dependencies list:

```bash

$ mix deps.get
```
