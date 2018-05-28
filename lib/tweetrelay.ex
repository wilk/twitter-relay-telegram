defmodule TweetRelay do
  # macro "use" used to import GenServer and calling its __using__ method (GenServer.__using__())
  # GenServer: module to implement client-server applications
  use GenServer

  # start is called by the MixProject (application method "mod")
  def start(:normal, initial_state) do
    IO.puts("start")
    GenServer.start_link(__MODULE__, initial_state)
  end

  # GenServer init implementation, called by MixProject application
  def init(state) do
    IO.puts("init")

    {:ok, updates} = Nadia.get_updates([limit: 100])
    if length(updates) > 0 do
      flush_updates(updates)
    end

    schedule_work()
    {:ok, state}
  end

  defp flush_updates(list) when length(list) == 0 do
    IO.puts("emptied list, no more unread messages")
  end

  defp flush_updates(list) do
    last_command = Enum.at(list, length(list) - 1)
    {:ok, updates} = Nadia.get_updates([limit: 1, offset: last_command.update_id+1])
    flush_updates(updates)
  end

  defp schedule_work() do
    IO.puts("schedule_work")
    Process.send_after(self(), :work, 1000)
  end

  # server
  # handle_info receives messages sent by Process.send_after/4 and Kernel.send/2
  def handle_info(:work, state) do
    IO.puts("handle_info")

    # case returns a list in both case (ok or error), ignoring errors
    updates = case Nadia.get_updates([limit: 1]) do
      {:ok, updates} -> updates
      {:error, err} ->
        IO.inspect(err)
        []
    end

    state = if (length(updates) > 0) do
      # it fetches the last message sent and analyze it
      command = Enum.at(updates, 0)

      # cond is a set of "if" statements grouped together
      state = cond do
        # /help check
        command.message.text === "/help" ->
          Nadia.send_message(command.message.chat.id, """
          Hello, I'm the digest bot and I can help you crawling Twitter for you.

          Following the available commands list:

          /list: list all the followed interestes
          /follow interest[,...]: start following one or more interests
          /unfollow interest[,...]: unfollow one or more interests
          /digest: get the last 5 tweets of the followed interests in digest format

          Start by adding new interests to follow and then invoke "/digest" to see what happens!
          """)

          state
        # /list check
        command.message.text === "/list" ->
          message = get_list_response(state)
          Nadia.send_message(command.message.chat.id, message)

          state
        # /follow check
        String.starts_with?(command.message.text, "/follow") ->
          followersList = String.replace(command.message.text, "/follow", "")
          state = followersList
           |> String.replace(" ", "")
           |> String.split(",")
           |> follow(state)

          Nadia.send_message(command.message.chat.id, "followed: " <> followersList)

          state
        # /unfollow check
        String.starts_with?(command.message.text, "/unfollow") ->
          followersList = String.replace(command.message.text, "/unfollow", "")
          state = followersList
            |> String.replace(" ", "")
            |> String.split(",")
            |> unfollow(state)

           Nadia.send_message(command.message.chat.id, "unfollowed: " <> followersList)

           state
        # /digest check
        String.starts_with?(command.message.text, "/digest") ->
          tweets = get_digest(state)

          Nadia.send_message(command.message.chat.id, tweets)

          state
      end

      flush_updates(updates)
      state
    else
      state
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
