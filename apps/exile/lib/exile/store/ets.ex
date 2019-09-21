defmodule Exile.Store.ETS do
  @moduledoc """
  An ETS backed implementation of an `Exile.Store`.
  """

  alias Exile.Store.ETS.Table

  @behaviour Exile.Store

  @impl Exile.Store
  def get(_path) do
    :not_implemented
  end

  @impl Exile.Store
  def post(path, record) do
    Table.post(path, record)
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

defmodule Exile.Store.ETS.Table do
  use GenServer

  @server __MODULE__
  @supervisor __MODULE__.Supervisor
  @registry __MODULE__.Registry
  @table_opts [:set, :protected]

  import @registry, only: [via_registry: 1, exists?: 1]

  @doc false
  def child_spec(path_root) do
    id = Exile.Path.root(path_root)

    %{
      id: id,
      restart: :temporary,
      start: {__MODULE__, :start_link, []}
    }
  end

  @doc false
  def table_ref(path) do
    path_root = Exile.Path.root(path)
    # Ensure it is started.
    DynamicSupervisor.start_child(@supervisor, child_spec(path_root))
    path_root
  end

  def post(path, record) do
    path
    |> table_ref()

    # TODO Perform operation based on POST specification
    :not_implemented
  end

  @doc false
  def start_link(args) do
    GenServer.start_link(@server, args, name: via_registry(id))
  end

  @doc false
  @impl GenServer
  def init(id) do
    Logger.debug("[id: #{id}] New Table created.")

    # We may wish to limit the number of ETS table per node
    table_name =
      id
      |> String.to_atom(id)
      |> :ets.new()

    {:ok, %{id: id, table_name: table_name}}
  end
end

defmodule Exile.Store.ETS.Table.Registry do
  @registry_name __MODULE__

  defmacro __using__(_opts) do
    quote do
      import Exile.ETS.Table.Registry, only: [via_registry: 1, whereis_name: 1, exists?: 1]
    end
  end

  @doc "Child Specification for `#{__MODULE__}`"
  @spec child_spec :: map()
  def child_spec() do
    %{
      id: __MODULE__,
      start: {Registry, :start_link, [[keys: :unique, name: @registry_name]]}
    }
  end

  @spec via_registry(Cola.Form.ref()) :: tuple()
  def via_registry(ref) do
    {:via, Registry, {@registry_name, ref}}
  end

  def whereis_name(ref) do
    Registry.whereis_name({@registry_name, ref})
  end

  def exists?(ref), do: whereis_name(ref) != :undefined
end

defmodule Exile.Store.ETS.Table.Supervisor do
  @moduledoc """
  `DyanmicSupervisor` for `Exile.Store.ETS.Table` processes.
  """

  def child_spec() do
    {DynamicSupervisor, strategy: :one_for_one, name: __MODULE__}
  end
end
