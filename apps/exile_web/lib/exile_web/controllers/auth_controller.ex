defmodule ExileWeb.AuthController do
  use ExileWeb, :controller

  alias ExileAuth.Accounts

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Accounts.authenticate_user(username, password)
    |> login_reply(conn)
  end

  defp login_reply({:ok, user}, conn) do
    {:ok, token, _claims} = ExileAuth.Guardian.encode_and_sign(user, %{})
    conn
    |> put_status(200)
    |> json(%{token: token})
  end

  defp login_reply(err, conn) do
    conn
    |> ExileWeb.AuthErrorHandler.auth_error(err, %{})
  end
end

defmodule ExileWeb.Plug.AuthAccessPipeline do
  use Guardian.Plug.Pipeline,
    module: ExileAuth.Guardian,
    otp_app: :exile_web,
    error_handler: ExileWeb.AuthErrorHandler
  
  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.EnsureAuthenticated

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule ExileWeb.AuthErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, "Authentication failed: #{body}")
  end
end
