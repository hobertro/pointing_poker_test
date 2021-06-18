defmodule PointingPokerGameTest do
  use ExUnit.Case
  alias PointingPoker.Game
  alias PointingPoker.Player

  test "tallys votes" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.add_player(game, "b", "homan")
    game = Game.player_voted(game, "a", 1)
    game = Game.player_voted(game, "b", 3)
    game = Game.reveal_votes(game)
    assert game.state == {:show_votes, 2.0}
  end

  test "ignores abstained voting" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.add_player(game, "b", "homan")
    game = Game.player_voted(game, "a", 1)
    game = Game.player_voted(game, "b", "?")
    game = Game.reveal_votes(game)
    assert game.state == {:show_votes, 1.0}
  end

  test "allows update score after revealing votes" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.add_player(game, "b", "homan")
    game = Game.player_voted(game, "a", 1)
    game = Game.player_voted(game, "b", "?")
    game = Game.reveal_votes(game)
    assert game.state == {:show_votes, 1.0}
    game = Game.player_voted(game, "b", 3)
    assert game.state == {:show_votes, 2.0}
  end

  test "score is ? if no one votes" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.reveal_votes(game)
    assert game.state == {:show_votes, "?"}
  end

  test "removing a player" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    assert length(game.players) == 1
    game = Game.remove_player(game, "a")
    assert length(game.players) == 0
  end

  test "attempting to add same player id does not duplicate player" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.add_player(game, "a", "bobby")
    assert length(game.players) == 1
  end

  test "attempting to add same player id does not change vote" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.player_voted(game, "a", 3)
    game = Game.add_player(game, "a", "bobby")
    player = Game.find_player(game.players, "a")
    assert Player.get_numerical_vote(player) == 3
  end

  test "if all players that can vote, voted, then reveal votes" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.add_player(game, "b", "homan")
    game = Game.player_voted(game, "a", 3)
    game = Game.player_voted(game, "b", 1)
    assert game.state == {:show_votes, 2.0}
  end

  test "if a player disconnects, disconnected_at should be a timestamp" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.disconnect_player(game, "a")
    player = Game.find_player(game.players, "a")
    refute player.disconnected_at == nil
  end

  test "if a player reconnects, timestamp should be cleared" do
    game = Game.new()
    game = Game.add_player(game, "a", "bobby")
    game = Game.disconnect_player(game, "a")
    player = Game.find_player(game.players, "a")
    game = Game.reconnect_player(game, "a")
    player = Game.find_player(game.players, "a")
    assert player.disconnected_at == nil
  end
end
