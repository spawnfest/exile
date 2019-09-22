defmodule ExileWeb.ListLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <form phx-change="update" phx-submit="update">
        <div class="form-group">
          <label for="reference">Reference</label>
          <input class="form-control" type="text" name="reference" value="<%= @reference %>" autocomplete="off">
          </input>
        </div>
      </form>
      <hr/>
      <table class="table mb-0">
        <thead>
          <tr>
            <th>ID</th>
            <th>Timestamp</th>
            <th>Value</th>
          </tr>
        </thead>
        <%= if Enum.empty?(assigns.entries) do %>
          <tr>
            <td colspan="3">
              No Entries
            </td>
          </tr>
        <% end %>
        <%= for entry <- assigns.entries do %>
          <tr>
            <td><%= entry.id %></td>
            <td><%= entry.ts %></td>
            <td>
              <pre><%= inspect entry.value, pretty: true %></pre>
            </td>
          </tr>
        <% end %>
      </table>
    """
  end
  
  def mount(session, socket) do
    reference = session.prefix <> ":" <> session.reference
    :ok = Exile.subscribe(reference, self())
    {:ok, entries} = Exile.get(reference)
    {:ok, assign(socket, prefix: session.prefix, reference: session.reference, entries: entries)}
  end

  def handle_info({:exile_event, _}, socket) do
    with %{assigns: %{reference: reference}} <- socket,
         {:ok, entries} when is_list(entries) <- Exile.get(path(reference, socket)) do
      {:noreply, assign(socket, entries: entries)}
    else
      _ -> {:noreply, assign(socket, entries: [])}
    end
  end

  def handle_event("update", %{"reference" => ""}, socket) do
    :ok = Exile.unsubscribe(path(socket.assigns.reference, socket))
    {:noreply, assign(socket, reference: nil, entries: [])}
  end

  def handle_event("update", %{"reference" => reference}, socket) do
    if is_binary(socket.assigns.reference) do
      :ok = Exile.unsubscribe(path(socket.assigns.reference, socket))
    end

    with :ok = Exile.subscribe(socket.assigns.prefix <> ":" <> reference),
         {:ok, entries} when is_list(entries) <- Exile.get(path(reference, socket)) do
      {:noreply, assign(socket, reference: reference, entries: entries)}
    else
      _ -> {:noreply, assign(socket, reference: reference, entries: [])}
    end
  end

  defp path(reference, socket) do
    with true <- is_binary(reference),
         [head|rest] <- Path.split(reference) do
      Path.join([socket.assigns.prefix <> ":" <> head | rest])
    else
      _ -> ""
    end
  end
end
