defmodule ExileWeb.DatabaseChannel do
  use Phoenix.Channel

  def join("database:" <> prefix, message, socket) do
    IO.inspect [__MODULE__, prefix, message, socket]
    {:ok, socket}
  end
end
