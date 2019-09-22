defmodule ExileWeb.UserController do
  use ExileWeb, :controller

  alias ExileAuth.{Accounts, Accounts.User}

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> put_status(:created)
        |> put_resp_content_type("application/json")
        |> json(%{ok: user.username})
      {:error, %Ecto.Changeset{errors: errors}} ->
        conn
        |> send_resp(400, "Unable to create user")
    end
  end
end
