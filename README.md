# Tweetrelay
This is an application implemented by myself to learn and understand Elixir.
It's meant to be used as a tutorial for beginners.
Feel free to improve source code and docs.

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
