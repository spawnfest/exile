defmodule ExileWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: ExileWeb
      import Plug.Conn
      import ExileWeb.Gettext
      alias ExileWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/exile_web/templates", namespace: ExileWeb
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
      use Phoenix.HTML
      import ExileWeb.ErrorHelpers
      import ExileWeb.Gettext
      alias ExileWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ExileWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
