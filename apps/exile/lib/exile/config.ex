defmodule Exile.Config do
  @moduledoc """
  Configuration helpers for `Exile` system.
  """

  @default Exile.Store.ETS

  @doc "Get storage provider of default to #{@default}"
  def store() do
    Application.get_env(Exile, :store, @default)
  end
end
