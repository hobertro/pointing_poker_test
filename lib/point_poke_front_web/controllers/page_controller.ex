defmodule PointPokeFrontWeb.PageController do
  use PointPokeFrontWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
