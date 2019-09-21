defmodule ExileWeb.Router do
  use ExileWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExileWeb do
    pipe_through :api
  end
end
