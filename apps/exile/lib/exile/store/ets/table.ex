defmodule Exile.Store.ETS.Table do
  use GenServer

  alias __MODULE__.Supervisor, as: TableSupervisor
  alias __MODULE__.Registry, as: TableRegistry

  import TableRegistry, only: [via_registry: 1]

  require Logger

  @server __MODULE__
  @table_opts [:set, :protected, :named_table, read_concurrency: true]

  @doc false
  def child_spec(table_ref) do
    %{
      id: table_ref,
      restart: :temporary,
      start: {__MODULE__, :start_link, [table_ref]}
    }
  end

  @doc false
  def table_ref(path) do
    table_ref = Exile.Path.to_ref(path)

    case TableSupervisor.start_child(child_spec(table_ref)) do
      {:error, {:already_started, _}} -> via_registry(table_ref)
      {:ok, _} -> via_registry(table_ref)
      error -> raise "Failed to start #{__MODULE__} process: #{inspect(error)}"
    end
  end

  def post(path, record) do
    GenServer.call(table_ref(path), {:post, path, record})
  end

  def get(path) do
    all =
      path
      |> table_name_for_path!()
      |> :ets.tab2list()

    {:ok, all}
  rescue
    ArgumentError ->
      {:error, :not_found}
  end

  def delete(path) do
    GenServer.call(table_ref(path), {:delete, path})
  end

  @doc false
  def start_link(args) do
    id = args
    GenServer.start_link(@server, args, name: via_registry(id))
  end

  @doc false
  @impl GenServer
  def init(table_ref) do
    Logger.debug("#{log_prefix()} [INIT] New Table created @ #{table_ref}")

    table_name =
      table_ref
      |> table_name_from_ref()
      |> :ets.new(@table_opts)

    {:ok, %{table_name: table_name}}
  end

  @impl GenServer
  def handle_call({:post, _path, record}, _, state) do
    row = Exile.Record.row(record)
    true = :ets.insert_new(state.table_name, row)
    {id, ts, body} = row
    Logger.debug("#{log_prefix()} [POST] Inserted #{id} @ #{ts} with #{inspect(body)}.")
    # TODO raise event
    {:reply, {:ok, id}, state}
  end

  @impl GenServer
  def handle_call({:delete, path}, _, state) do
    # This is deleting at root level
    path
    |> table_name_for_path!()
    |> :ets.delete()

    Logger.debug("#{log_prefix()} [DELETE] path: #{path}.")
    {:stop, :normal, :ok, state}
  end

  defp table_name_for_path!(path) do
    path
    |> Exile.Path.to_ref()
    |> String.to_existing_atom()
  end

  defp table_name_from_ref(table_ref) do
    table_ref
    |> String.to_atom()
  end

  defp log_prefix() do
    "[#{__MODULE__}]"
  end
end
