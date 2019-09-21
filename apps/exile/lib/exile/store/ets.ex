defmodule Exile.Store.ETS do
  @moduledoc """
  An ETS backed implementation of an `Exile.Store`.
  """

  @behaviour Exile.Store

  @impl Exile.Store
  def get(_path) do
    :not_implemented
  end

  @impl Exile.Store
  def post(_path, _record) do
    :not_implemented
  end

  @impl Exile.Store
  def put(_path, _record) do
    :not_implemented
  end

  @impl Exile.Store
  def delete(_path) do
    :not_implemented
  end

  @impl Exile.Store
  def subscribe(_path, _subscriber) do
    :not_implemented
  end

  @impl Exile.Store
  def unsubscribe(_path, _subscriber) do
    :not_implemented
  end
end

defmodule Exile.Store.ETS.Root do
end

defmodule Exile.Store.ETS.Root.Registry do
end

defmodule Exile.Store.ETS.Root.Supervisor do
end
