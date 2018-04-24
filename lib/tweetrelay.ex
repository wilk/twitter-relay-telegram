defmodule TweetRelay do
  use GenServer, restart: :permanent, shutdown: 10_000

  children = [
    {TweetRelay, [:init]}
  ]

  def start(:normal, args) do
    IO.puts "meh"
    {:ok, state} = GenServer.start_link(__MODULE__, args)
    IO.puts "kgh"
    {:ok, state}
  end

  # client
  def init(state) do
    IO.puts "wat"
    schedule_work()
    {:ok, state}
  end

  def schedule_work() do
    IO.puts "MMM"
    Process.send_after(self(), :work, 10000)
  end

  # server
  def handle_info(:work, state) do
    IO.puts "HANDLE"
    a = ExTwitter.search("@rep_tecno", [count: 5])
      |> Enum.map(fn(tweet) -> tweet.text end)
      |> Enum.join("\n-----\n")
    Nadia.send_message(Application.get_env(:nadia, :chat_id), a)

    schedule_work()
    {:noreply, state}
  end
end
