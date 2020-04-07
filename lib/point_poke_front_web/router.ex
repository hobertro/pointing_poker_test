defmodule PointPokeFrontWeb.Router do
  use PointPokeFrontWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    # plug :fetch_flash
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(PointPokeFrontWeb.TagUser)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PointPokeFrontWeb do
    pipe_through(:browser)
    get("/games/:id", GameController, :play)
    # resources("/games", GameController, only: [:new, :create, :show])
    # match(:post, "/games/join", GameController, :join)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PointPokeFrontWeb do
  #   pipe_through :api
  # end
end
