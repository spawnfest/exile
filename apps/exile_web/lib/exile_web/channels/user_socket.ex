defmodule ExileWeb.UserSocket do
  use Phoenix.Socket
  channel "database:*", ExileWeb.DatabaseChannel

  def connect(_params, socket, _connect_info), do: {:ok, socket}
  def id(_socket), do: nil
end
