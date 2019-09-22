defmodule ExileWeb.ListLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <form phx-change="update">
        <div class="form-group">
          <label for="reference">Reference</label>
          <input class="form-control" type="text" name="reference" value="<%= @reference %>">
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

  def handle_info({:exile_event, {:new, _, {id, ts, value}}}, socket) do
    entry = %{id: id, ts: ts, value: value}
    entries = [entry | socket.assigns.entries]
    {:noreply, assign(socket, entries: entries)}
  end

  def handle_info({:exile_event, {:update, _, {id, ts, value}}}, socket) do
    entry = %{id: id, ts: ts, value: value}
    entries = put_in(socket.assigns.entries, [Access.filter(& &1.id == id)], entry)
    {:noreply, assign(socket, entries: entries)}
  end
  
  def handle_event("update", %{"reference" => reference}, socket) do
    :ok = Exile.unsubscribe(socket.assigns.prefix <> ":" <> socket.assigns.reference)
    :ok = Exile.subscribe(socket.assigns.prefix <> ":" <> reference)
    
    case Exile.get(socket.assigns.prefix <> ":" <> reference) do
      {:ok, entries} -> {:noreply, assign(socket, reference: reference, entries: entries)}
      _ -> {:noreply, assign(socket, reference: reference, entries: [])}
    end
  end
end
