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
      {:ok, value} -> {:reply, {:ok, %{result: "ok", reference: reference, value: value}}, socket}
      {:error, reason} -> {:reply, {:ok, %{result: "error", reason: reason}}, socket}
    end
  end

  def handle_in("post", %{"reference" => reference, "value" => value}, socket) do
    case Exile.post(path(reference, socket), value) do
      {:ok, value} -> {:reply, {:ok, %{result: "ok", reference: reference, value: value}}, socket}
      {:error, reason} -> {:reply, {:ok, %{result: "error", reason: reason}}, socket}
    end
  end

  def handle_in("put", %{"reference" => reference, "value" => value}, socket) do
    case Exile.put(path(reference, socket), value) do
      {:ok, value} -> {:reply, {:ok, %{result: "ok", reference: reference, value: value}}, socket}
      {:error, reason} -> {:reply, {:ok, %{result: "error", reason: reason}}, socket}
    end
  end

  def handle_in(_, _, socket) do
    {:reply, {:ok, %{result: "error", reason: "badarg"}}, socket}
  end

  defp path(reference, socket) do
    [head|rest] = Path.split(reference)
    Path.join([socket.assigns.prefix <> ":" <> head | rest])
  end
end
