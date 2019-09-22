defmodule Exile.Store.ETS.Table.Supervisor do
  @moduledoc """
  `DyanmicSupervisor` for `Exile.Store.ETS.Table` processes.
  """

  def child_spec() do
    {DynamicSupervisor, strategy: :one_for_one, name: __MODULE__}
  end

  @doc "Will start a `Exile.ETS.Table` Process if not already started."
  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
