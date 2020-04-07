defmodule PointPokeFrontWeb.TagUser do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    user_tag = conn |> get_session(:user_tag)

    if user_tag == nil do
      conn |> put_session(:user_tag, PointingPoker.Util.random_id(5))
    else
      conn
    end
  end
end
