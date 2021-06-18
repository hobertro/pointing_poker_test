defmodule PointingPoker.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """
  alias PointingPoker.Util
  alias PointingPoker.Game
  use GenServer
  require Logger

  @timeout :timer.hours(2)

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_id) do
    GenServer.start_link(
      __MODULE__,
      :ok,
      name: via_tuple(game_id)
    )
  end

  def join_game(game_id, player_id, player_name, observer \\ false) do
    GenServer.call(via_tuple(game_id), {:join_game, player_id, player_name, observer})
  end

  def player_disconnected(game_id, player_id) do
    GenServer.call(via_tuple(game_id), {:player_disconnected, player_id})
  end

  def player_reconnected(game_id, player_id) do
    GenServer.call(via_tuple(game_id), {:player_reconnected, player_id})
  end

  def leave_game(game_id, player_id) do
    GenServer.cast(via_tuple(game_id), {:leave_game, player_id})
  end

  def summary(game_id) do
    GenServer.call(via_tuple(game_id), :summary)
  end

  def vote(game_id, player_id, vote) do
    GenServer.call(via_tuple(game_id), {:vote, player_id, vote})
  end

  def reveal_votes(game_id) do
    GenServer.call(via_tuple(game_id), :reveal_votes)
  end

  def clear_votes(game_id) do
    GenServer.call(via_tuple(game_id), :clear_votes)
  end

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_id) do
    {:via, Registry, {PointingPoker.GameRegistry, game_id}}
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_id) do
    game_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server Callbacks

  def init(:ok) do
    game = Game.new()
    {:ok, game, @timeout}
  end

  def handle_call({:join_game, player_id, player_name, observer}, _from, game) do
    game = Game.add_player(game, player_id, player_name, observer)
    {:reply, game, game, @timeout}
  end

  def handle_call({:player_disconnected, player_id}, _from, game) do
    game = Game.disconnect_player(game, player_id)
    Process.send_after(self, :kick_check, 5000)
    {:reply, game, game, @timeout}
  end

  def handle_call(:summary, _from, game) do
    {:reply, game, game, @timeout}
  end

  def handle_call({:vote, player_id, vote}, _from, game) do
    game = Game.player_voted(game, player_id, vote)
    {:reply, game, game, @timeout}
  end

  def handle_call(:reveal_votes, _from, game) do
    game = Game.reveal_votes(game)
    {:reply, game, game, @timeout}
  end

  def handle_call(:clear_votes, _from, game) do
    game = Game.clear_votes(game)
    {:reply, game, game, @timeout}
  end

  def handle_cast({:leave_game, player_id}, game) do
    game = Game.remove_player(game, player_id)
    {:noreply, game}
  end

  def handle_info(:kick_check, game) do
    {earlier, _} = NaiveDateTime.add(NaiveDateTime.utc_now(), -4) |> NaiveDateTime.to_gregorian_seconds()
    eligible_to_kick = Enum.filter(game.players, fn player -> player.disconnected_at < earlier end)
    new_game = Enum.reduce(game.players, game, fn player, acc ->
      if player.disconnected_at < earlier do
        Game.remove_player(game, player.id)
      else
        acc
      end
    end)

    {:noreply, new_game}
  end

  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, _game) do
    # :ets.delete(:games_table, my_game_name())
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  # defp my_game_name do
  #   Registry.keys(Bingo.GameRegistry, self()) |> List.first
  # end
end
