defmodule Exile.Store.ETS.Table do
  use GenServer

  alias __MODULE__.Supervisor, as: TableSupervisor
  alias __MODULE__.Registry, as: TableRegistry

  import TableRegistry, only: [via_registry: 1]

  require Logger

  @server __MODULE__
  @table_opts [:set, :protected]

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

  @doc false
  def start_link(args) do
    id = args
    GenServer.start_link(@server, args, name: via_registry(id))
  end

  @doc false
  @impl GenServer
  def init(table_ref) do
    Logger.debug("[id: #{table_ref}] New Table created.")

    # We may wish to limit the number of ETS table per node
    table_name =
      table_ref
      |> String.to_atom()
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

  defp log_prefix() do
    "[#{__MODULE__}]"
  end
end
