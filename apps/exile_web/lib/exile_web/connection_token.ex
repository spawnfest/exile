defmodule ExileWeb.ConnectionToken do
  @moduledoc """
  Token wrapping a set prefix so the demo page uses a namespace. This token is used between the
  publicly available PageController and the DatabaseChannel to determine what prefix the db calls
  will be given, etc.
  """

  @type t :: %__MODULE__{prefix: String.t()}
  @enforce_keys ~w(prefix)a
  defstruct prefix: nil

  @token_salt "cook the fish"
  @token_ttl 86400

  def encode(map) do
    sign(struct(__MODULE__, map))
  end

  def sign(%__MODULE__{} = token) do
    Phoenix.Token.sign(ExileWeb.Endpoint, @token_salt, token)
  end

  def verify(string) do
    case Phoenix.Token.verify(ExileWeb.Endpoint, @token_salt, string, max_age: @token_ttl) do
      {:ok, %__MODULE__{} = token} -> {:ok, token}
      {:ok, _} -> {:error, :malformed_token}
      {:error, reason} -> {:error, reason}
    end
  end
end
