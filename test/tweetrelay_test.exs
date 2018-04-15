defmodule TweetrelayTest do
  use ExUnit.Case
  doctest Tweetrelay

  test "greets the world" do
    assert Tweetrelay.hello() == :world
  end
end
