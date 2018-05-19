defmodule TweetRelay do
  # macro "use" used to import GenServer and calling its __using__ method (GenServer.__using__())
  use GenServer

  def start(:normal, _) do
    IO.puts "start"
    GenServer.start_link(__MODULE__, [])
  end

  # client
  def init(state) do
    IO.puts "init"

    IO.inspect Nadia.get_me
    {:ok, updates} =  Nadia.get_updates([limit: 100])
    if Kernel.length(updates) > 0 do
      flush_updates(updates)
    end

    schedule_work()
    {:ok, state}
  end

  defp flush_updates(list) when Kernel.length(list) == 0 do
    IO.puts "emptied list, no more unread messages"
  end

  defp flush_updates(list) do
    last_command = Enum.at(list, Kernel.length(list) - 1)
    {:ok, updates} =  Nadia.get_updates([limit: 1, offset: last_command.update_id+1])
    flush_updates(updates)
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
    IO.puts "handle_info"

    #result = ExTwitter.search("@rep_tecno", [count: 5])
    #  |> Enum.map(fn(tweet) -> IO.inspect tweet; tweet.text end)
    #  |> Enum.join("\n-----\n")
    #Nadia.send_message(Application.get_env(:nadia, :chat_id), result)

    # todo: parse the following commands
    # /follow : add someone to the followers list
    # /unfollow : remove someone from the followers list
    # /list : list who you're following
    # /digest [amount = 1] : get the last tweets grouped by followers

    # todo: update to the last telegram message
    {:ok, updates} =  Nadia.get_updates([limit: 1])
    #case Nadia.get_updates([limit: 1, offset: state[:last_command].update_id+ 1]) do
    #  {:ok, updates} -> updates
    #  {:error} -> :error
    #end
    #Enum.map(updates, fn(update) -> IO.inspect update end)
    #IO.inspect commands

    if (Kernel.length(updates) > 0) do
      command = Enum.at(updates, 0)

      case command.message.text do
        "/list" -> display_list(state)
        # String.starts_with?(message, "/follow") -> String.replace(message, "/follow", "")
        #   |> String.replace(" ", "")
        #   |> String.split(",")
        #   |> TweetRelay.follow()
        # String.starts_with?(message, "/unfollow") -> String.replace(message, "/unfollow", "")
        #   |> String.replace(" ", "")
        #   |> String.split(",")
        #   |> TweetRelay.unfollow()
        # String.starts_with?(message, "/digest") -> String.replace(message, "digest", "")
        #   |> String.replace(" ", "")
        #   |> TweetRelay.digest()
      end

      flush_updates(updates)
    end

    #{:ok, last_command} = Enum.fetch(updates, 0)
    #IO.puts last_command.message.text
    #IO.puts state[:last_command].message.text
    #IO.puts last_command.update_id

    #if last_command.message.message_id != state[:last_command].message.message_id do
      #Nadia.send_message(Application.get_env(:nadia, :chat_id), last_command.message.text)
      #state = Map.put(state, :last_command, last_command)
    #end

    schedule_work()
    {:noreply, state}
  end

  defp display_list(state) do
    # todo: display followers list
    message = "You're following no one. Type \"/follow @__wilkyz__\" to follow someone."
    if (Kernel.length(state) > 0) do
      message = Enum.join(state, ", ")
    end

    Nadia.send_message(Application.get_env(:nadia, :chat_id), message)
  end

  defp follow(interests, state) do
    # todo: follow a list of interests
  end

  defp unfollow(interests) do
    # todo: unfollow a list of interests
  end

  defp digest(amount=5) do
    # todo: send first $amount tweets in a digest form
  end
end
