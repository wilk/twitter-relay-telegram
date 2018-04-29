defmodule TweetRelay do
  use GenServer

  def start(:normal, args) do
    IO.puts "start"
    GenServer.start_link(__MODULE__, args)
  end

  # client
  def init(state) do
    IO.puts "wat"
    schedule_work()
    {:ok, state}
  end

  defp schedule_work() do
    IO.puts "MMM"
    #Process.send_after(self(), :work, 2000)
    :timer.sleep(10000)
    handle_info(:work, self())
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
