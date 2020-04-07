defmodule PointingPoker.GameSupervisor do
  use DynamicSupervisor

  alias PointingPoker.GameServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `GameServer` process and supervises it.
  """
  def start_game(game_id) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, game_id})
  end

  @doc """
  Terminates the `GameServer` process normally. It won't be restarted.
  """
  def stop_game(game_id) do
    child_pid = GameServer.game_pid(game_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end
end
