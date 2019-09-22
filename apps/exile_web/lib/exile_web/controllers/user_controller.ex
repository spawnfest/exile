defmodule ExileWeb.UserController do
  use ExileWeb, :controller

  alias ExileAuth.{Accounts, Accounts.User}

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> json(%{ok: user.username})
    end
  end
end
