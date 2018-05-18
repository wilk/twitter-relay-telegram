defmodule TweetRelay do
  # macro "use" used to import GenServer and calling its __using__ method (GenServer.__using__())
  use GenServer

  def start(:normal, _) do
    IO.puts "start"
    GenServer.start_link(__MODULE__, %{})
  end

  # client
  def init(state) do
    IO.puts "init"
    #{:ok, table} = :dets.open_file(:disk_storage, [type: :set])
    #:dets.insert_new(table, {"meh", "asd", ["Elixir", "Go", "Rust"]})
    #a = :dets.lookup(table, "meh")
    #state = Map.put(state, :last_command, table)
    #IO.inspect state
    #IO.inspect a
    {:ok, updates} =  Nadia.get_updates([limit: 1])
    {:ok, last_command} = Enum.fetch(updates, 0)
    state = Map.put(state, :last_command, last_command)
    schedule_work()
    {:ok, state}
  end

  defp schedule_work() do
    IO.puts "schedule_work"
    Process.send_after(self(), :work, 1000)
  end

  # server
  def handle_info(:work, state) do
    #IO.inspect state
    #a = :dets.lookup(state[:table], "meh")
    #IO.inspect a
    #IO.puts "handle_info"

    #result = ExTwitter.search("@rep_tecno", [count: 5])
    #  |> Enum.map(fn(tweet) -> IO.inspect tweet; tweet.text end)
    #  |> Enum.join("\n-----\n")
    #Nadia.send_message(Application.get_env(:nadia, :chat_id), result)

    # todo: parse the following commands
    # /follow : add someone to the followers list
    # /unfollow : remove someone from the followers list
    # /list : list who you're following
    # /digest [amount = 1] : get the last tweets grouped by followers

    {:ok, updates} =  Nadia.get_updates([limit: 1, offset: state[:last_command].update_id+ 1])
    #Enum.map(updates, fn(update) -> IO.inspect update end)
    #IO.inspect commands

    {:ok, last_command} = Enum.fetch(updates, 0)
    IO.puts last_command.message.text
    IO.puts state[:last_command].message.text
    IO.puts last_command.update_id

    if last_command.message.message_id != state[:last_command].message.message_id do
      #Nadia.send_message(Application.get_env(:nadia, :chat_id), last_command.message.text)
      state = Map.put(state, :last_command, last_command)
    end

    schedule_work()
    {:noreply, state}
  end
end
