defmodule ExileWeb.DatabaseChannel do
  use Phoenix.Channel
  alias ExileWeb.ConnectionToken

  def join("database:" <> prefix, %{"token" => token}, socket) do
    case ConnectionToken.verify(token) do
      {:ok, %{prefix: ^prefix}} -> {:ok, assign(socket, :prefix,  prefix)}
      _ -> :error
    end
  end

  def handle_in("get", %{"reference" => reference}, socket) do
    case Exile.get(path(reference, socket)) do
      {:ok, value} -> push(socket, "ok", %{reference: reference, value: value})
      {:error, reason} -> push(socket, "error", %{reason: reason})
    end

    {:noreply, socket}
  end

  def handle_in("post", %{"reference" => reference, "value" => value}, socket) do
    case Exile.post(path(reference, socket), value) do
      {:ok, value} -> push(socket, "ok", %{reference: reference, value: value})
      {:error, reason} -> push(socket, "error", %{reason: reason})
    end

    {:noreply, socket}
  end

  defp path(reference, socket) do
    Path.join([socket.assigns.prefix, reference])
  end
end
