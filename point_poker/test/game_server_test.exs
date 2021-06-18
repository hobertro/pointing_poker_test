defmodule PointingPokerGameServerTest do
  use ExUnit.Case
  alias PointingPoker.GameServer
  alias PointingPoker.Game

  test "spawning a game server" do
    game_id = "howdy"
    assert {:ok, _pid} = GameServer.start_link(game_id)
  end

  test "joining a game" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.join_game(game_id, "b", "homan")

    assert Enum.count(GameServer.summary(game_id).players) == 2
  end

  test "leaving a game" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.leave_game(game_id, "a")
    assert Enum.count(GameServer.summary(game_id).players) == 0
  end

  test "voting" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.vote(game_id, "a", 3)
    assert Game.everyone_voted(GameServer.summary(game_id).players) == true
  end

  test "show votes" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.join_game(game_id, "b", "homan")
    GameServer.vote(game_id, "a", 3)
    GameServer.reveal_votes(game_id)
    summary = GameServer.summary(game_id)
    assert {:show_votes, _} = summary.state
  end

  test "clear votes" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.join_game(game_id, "b", "homan")
    GameServer.vote(game_id, "a", 3)
    GameServer.clear_votes(game_id)
    summary = GameServer.summary(game_id)
    assert :voting = summary.state
  end

  test "disconnecting to a game" do
    game_id = "howdy"
    GameServer.start_link(game_id)
    GameServer.join_game(game_id, "a", "bobby")
    GameServer.player_disconnected(game_id, "a")
    :timer.sleep(6000)
    game = GameServer.summary(game_id)
    assert game.players |> length() == 0
  end

  # test "reconnecting to a game" do

  # end
end
