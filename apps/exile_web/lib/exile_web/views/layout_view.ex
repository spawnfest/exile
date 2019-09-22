defmodule ExileWeb.LayoutView do
  use ExileWeb, :view
  alias ExileWeb.Endpoint
  alias ExileWeb.Router.Helpers, as: Routes

  defp stylesheet_paths(assigns) do
    keys = [Access.key(:conn), Access.key(:private), Access.key(:stylesheet_names)]
    names = get_in(assigns, keys) || ["/css/screen-generic.css"]
    static_paths(names)
  end

  defp script_paths(assigns) do
    keys = [Access.key(:conn), Access.key(:private), Access.key(:script_names)]
    names = get_in(assigns, keys) || ["/js/screen-generic.js"]
    static_paths(names)
  end

  defp static_paths(names) do
    Enum.map(names, &Routes.static_path(Endpoint, &1))
  end
end
