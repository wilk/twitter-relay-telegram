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
    if length(updates) > 0 do
      flush_updates(updates)
    end

    schedule_work()
    {:ok, state}
  end

  defp flush_updates(list) when length(list) == 0 do
    IO.puts "emptied list, no more unread messages"
  end

  defp flush_updates(list) do
    last_command = Enum.at(list, length(list) - 1)
    {:ok, updates} =  Nadia.get_updates([limit: 1, offset: last_command.update_id+1])
    flush_updates(updates)
  end

  defp schedule_work() do
    IO.puts "schedule_work"
    Process.send_after(self(), :work, 1000)
  end

  # server
  def handle_info(:work, state) do
    IO.puts "handle_info"

    updates = case Nadia.get_updates([limit: 1]) do
      {:ok, updates} -> updates
      {:error, _} -> []
    end

    if (length(updates) > 0) do
      command = Enum.at(updates, 0)

      cond do
        command.message.text === "/list" ->
          message = get_list_response(state)
          Nadia.send_message(command.message.chat.id, message)
        String.starts_with?(command.message.text, "/follow") ->
          followersList = String.replace(command.message.text, "/follow", "")
          state = followersList
           |> String.replace(" ", "")
           |> String.split(",")
           |> follow(state)

          Nadia.send_message(command.message.chat.id, "followed: " <> followersList)
        String.starts_with?(command.message.text, "/unfollow") ->
          followersList = String.replace(command.message.text, "/unfollow", "")
          state = followersList
            |> String.replace(" ", "")
            |> String.split(",")
            |> unfollow(state)

           Nadia.send_message(command.message.chat.id, "unfollowed: " <> followersList)
        String.starts_with?(command.message.text, "/digest") ->
          tweets = get_digest(state)

          Nadia.send_message(command.message.chat.id, tweets)
      end

      flush_updates(updates)
    end

    schedule_work()
    {:noreply, state}
  end

  defp get_list_response(state) do
    if (length(state) > 0) do
      "Following: \n" <> Enum.join(state, ", ")
    else
      "You're following no one. Type \"/follow @__wilky__\" to follow someone."
    end
  end

  defp follow(interests, state) do
    new = Enum.filter(interests, fn(interest) -> !Enum.member?(state, interest) end)

    state ++ new
  end

  defp unfollow(interests, state) do
    existing = Enum.filter(interests, fn(interest) -> Enum.member?(state, interest) end)

    state -- existing
  end

  defp get_digest(state) do
    newsList = state
      |> Enum.map(fn(interest) -> Task.async(fn -> ExTwitter.search(interest, [count: 5]) end) end)
      |> Enum.map(fn(task) -> Task.await(task) end)
      |> Enum.map(fn(tweets) ->
        tweets |> Enum.map_join("\n", fn(tweet) ->
          IO.inspect(tweet)
          tweet.text
        end)
      end)

      0..(length(newsList) - 1)
        |> Stream.zip(newsList)
        |> Enum.map_join("\n", fn({k, v}) ->
          interest = Enum.at(state, k)
          "\n\nnews from " <> interest <> "\n\n" <> v
        end)
  end
end
