defmodule PointPokeFrontWeb.PageControllerTest do
  use PointPokeFrontWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "godaddy.com"
  end
end
