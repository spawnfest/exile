defmodule Exile.Store.ETS do
  @moduledoc """
  An ETS backed implementation of an `Exile.Store`.
  """

  alias Exile.Store.ETS.Table

  @behaviour Exile.Store

  @impl Exile.Store
  def get(path) do
    Table.get(path)
  end

  @impl Exile.Store
  def post(path, record) do
    Table.post(path, record)
  end

  @impl Exile.Store
  def put(path, record) do
    Table.put(path, record)
  end

  @impl Exile.Store
  def delete(path) do
    Table.delete(path)
  end

  @impl Exile.Store
  def subscribe(path, subscriber) do
    Table.subscribe(path, subscriber)
  end

  @impl Exile.Store
  def unsubscribe(_path, _subscriber) do
    :not_implemented
  end

  @impl Exile.Store
  def child_specs() do
    alias Exile.Store.ETS.Table.{Supervisor, Registry}

    [
      Supervisor.child_spec(),
      Registry.child_spec()
    ]
  end
end
