defmodule TweetRelay do
  use Application

  def start(_type, _args) do
    a = ExTwitter.search("@rep_tecno", [count: 5])
      |> Enum.map(fn(tweet) -> tweet.text end)
      |> Enum.join("\n-----\n")
    Nadia.send_message(Application.get_env(:nadia, :chat_id), a)
    Task.start(fn -> :timer.sleep(1000) end)
  end
end
