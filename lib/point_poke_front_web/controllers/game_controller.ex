defmodule PointPokeFrontWeb.GameController do
  use PointPokeFrontWeb, :controller

  alias PointingPoker.GameServer
  alias PointingPoker.GameSupervisor

  import Phoenix.LiveView.Controller

  def play(conn, %{"id" => game_id} = params) do
    if GameServer.game_pid(game_id) == nil do
      GameSupervisor.start_game(game_id)
    end

    live_render(conn, PointPokeFrontWeb.GameLive, session: %{"game_id" => game_id})

    # render(conn, "play.html", user_tag: user_tag, game_id: params["id"])
  end

  def new(conn, %{"id" => game_id} = params) do
    redirect(conn, to: "/games/#{game_id}")
    # render(conn, "play.html", user_tag: user_tag, game_id: params["id"])
  end

  # def new(conn, _params) do
  #   render(conn, "new.html")
  # end

  # def create(conn, _params) do
  # end

  # def show(conn, params) do
  # end

  # def join(conn, %{"game" => %{"id" => id}} = params) do
  #   if game_exists?(id) do
  #     # redirect to game
  #   else
  #     conn
  #     |> put_flash(:error, "Game ID \"#{id}\" not found")
  #     |> redirect(to: "/games/new")
  #   end
  # end

  # defp game_exists?(id) do
  #   false
  # end
end
