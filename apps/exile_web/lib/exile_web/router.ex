defmodule ExileWeb.Router do
  use ExileWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExileWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  pipeline :ensure_auth do
    plug ExileWeb.Plug.AuthAccessPipeline
  end

  # Other scopes may use custom stacks.
  scope "/api", ExileWeb do
    pipe_through :api

    scope "/auth" do
      get "/", AuthController, :test
      post "/login", AuthController, :login
    end

    put "/register", UserController, :create

    scope "/store" do
      pipe_through [:ensure_auth]
      get "/*path", StoreController, :get
      post "/*path", StoreController, :post
      put "/*path", StoreController, :put
      delete "/*path", StoreController, :delete
    end
  end
end
