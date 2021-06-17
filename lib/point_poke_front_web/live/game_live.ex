defmodule PointPokeFrontWeb.GameLive do
  use Phoenix.LiveView
  alias PointingPoker.Game
  alias PointingPoker.GameServer
  alias PointingPoker.Player
  alias Phoenix.Socket.Broadcast

  def render(assigns) do
    Phoenix.View.render(PointPokeFrontWeb.GameView, "index.html", assigns)
  end

  def find_player(game, user_tag) do
    Game.find_player(game.players, user_tag)
  end

  def mount(%{"game_id" => game_id, "user_tag" => user_tag} = session, socket) do
    summary = GameServer.summary(game_id)
    player = Game.find_player(summary.players, user_tag)

    # subscribe to pubsub on this game topic
    PointPokeFrontWeb.Endpoint.subscribe(game_id, [])

    {:ok,
     assign(socket,
       summary: summary,
       player: player,
       game_id: game_id,
       user_tag: user_tag
     )}
  end

  def handle_event("join_game", %{"player_name" => player_name}, socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.join_game(game_id, user_tag, player_name, false)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    player = Game.find_player(summary.players, user_tag)
    {:noreply, assign(socket, summary: summary, player: player)}
  end

  def handle_event("join_game", %{"player_name" => player_name, "is_observer" => _is_observer }, socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.join_game(game_id, user_tag, player_name, true)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    player = Game.find_player(summary.players, user_tag)
    {:noreply, assign(socket, summary: summary, player: player)}
  end

  def handle_event("player_voted", %{"vote" => "?"} = socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.vote(game_id, user_tag, "?")
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    {:noreply, assign(socket, summary: summary)}
  end

  def handle_event("player_voted", %{"vote" => vote} = socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    {vote, _} = Float.parse(vote)
    summary = GameServer.vote(game_id, user_tag, vote)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    {:noreply, assign(socket, summary: summary)}
  end

  def handle_event("show_votes", _params, socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.reveal_votes(game_id)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    {:noreply, assign(socket, summary: summary)}
  end

  def handle_event("clear_votes", _params, socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.clear_votes(game_id)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
    {:noreply, assign(socket, summary: summary)}
  end

  def handle_info(%Broadcast{event: "update", payload: %{summary: summary}} = event, socket) do
    {:noreply, assign(socket, summary: summary)}
  end

  def terminate(reason, socket) do
    %{game_id: game_id, user_tag: user_tag} = socket.assigns
    summary = GameServer.leave_game(game_id, user_tag)
    PointPokeFrontWeb.Endpoint.broadcast(game_id, "update", %{summary: summary})
  end
end
