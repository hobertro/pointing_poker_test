defmodule PointingPoker.Game do
  defstruct state: nil, players: []
  alias PointingPoker.Game
  alias PointingPoker.Util
  alias PointingPoker.Player

  def new() do
    %Game{state: :voting}
  end

  def find_player(players, id) do
    result = Enum.filter(players, fn existing_player -> id == existing_player.id end)

    case result do
      [] -> nil
      [player] -> player
    end
  end

  def add_player(%Game{} = game, id, name, observer \\ false) do
    case find_player(game.players, id) do
      nil ->
        %Game{game | players: [Player.new(id, name, observer) | game.players]}

      player ->
        # players = replace(game.players, id, fn player -> %Player{ player | name: name} end)

        # %Game{game | players: players}
        game
    end
  end

  def replace(players, id, replace_player_fn) do
    Enum.map(players, fn player ->
      if player.id == id do
        replace_player_fn.(player)
      else
        player
      end
    end)
  end

  def count_voters(players) do
    Enum.filter(players, fn player -> Player.eligible_to_vote(player) end) |> Enum.count()
  end

  def count_voted(players) do
    Enum.filter(players, fn player -> Player.voted?(player) end) |> Enum.count()
  end

  def everyone_voted(players) do
    count_eligible_to_vote = count_voters(players)

    if count_eligible_to_vote == count_voted(players) && count_eligible_to_vote > 0 do
      true
    else
      false
    end
  end

  def new_state(old_state, players) do
    if everyone_voted(players) do
      {:show_votes, calc_average_score(players)}
    else
      case old_state do
        :voting -> :voting
        {:show_votes, _} -> {:show_votes, calc_average_score(players)}
      end
    end
  end

  def player_voted(game, player_id, vote) do
    players = replace(game.players, player_id, fn player -> Player.vote(player, vote) end)

    %Game{game | state: new_state(game.state, players), players: players}
  end

  def calc_average_score(players) do
    votes =
      Enum.reduce(players, [], fn player, acc ->
        case Player.get_numerical_vote(player) do
          nil -> acc
          vote -> [vote | acc]
        end
      end)

    size = length(votes)

    case size do
      0 -> "?"
      size -> Enum.sum(votes) / size
    end
  end

  def reveal_votes(%Game{} = game) do
    score = calc_average_score(game.players)
    %Game{game | state: {:show_votes, score}}
  end

  def can_show_score?(%Game{} = game) do
    case game.state do
      :voting -> false
      _ -> true
    end
  end

  def score(%Game{} = game) do
    case game.state do
      :voting -> nil
      {:show_votes, vote} -> vote
    end
  end

  def clear_votes(%Game{} = game) do
    players =
      Enum.map(game.players, fn player ->
        Player.clear_vote(player)
      end)

    %Game{game | state: :voting, players: players}
  end

  def remove_player(%Game{} = game, player_id) do
    players = Enum.filter(game.players, fn player -> player.id != player_id end)
    %Game{game | state: new_state(game.state, players), players: players}
  end
end
