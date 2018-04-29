defmodule TweetRelay do
  use GenServer

  def start(:normal, args) do
    IO.puts "start"
    GenServer.start_link(__MODULE__, args)
  end

  # client
  def init(state) do
    IO.puts "init"
    schedule_work()
    {:ok, state}
  end

  defp schedule_work() do
    IO.puts "schedule_work"
    Process.send_after(self(), :work, 2000)
  end

  # server
  def handle_info(:work, state) do
    IO.puts "handle_info"

    a = ExTwitter.search("@rep_tecno", [count: 5])
      |> Enum.map(fn(tweet) -> tweet.text end)
      |> Enum.join("\n-----\n")
    Nadia.send_message(Application.get_env(:nadia, :chat_id), a)

    schedule_work()
    {:noreply, state}
  end
end
