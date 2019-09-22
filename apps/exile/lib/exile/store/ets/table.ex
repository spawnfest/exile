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
    case Exile.Path.parse(path) do
      [type: _root] ->
        all =
          path
          |> table_name_for_path!()
          |> :ets.tab2list()
          |> Enum.map(&row_to_record/1)

        {:ok, all}

      [_root, {:id, id}] ->
        get_root_record_by_id(path, id)

      [_root, {:id, id} | accessors] ->
        case get_root_record_by_id(path, id) do
          {:ok, record} ->
            access_value(record, accessors)
        end

      _ ->
        {:error, :not_found}
    end
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
  def handle_call({:post, path, record}, _, state) do
    res =
      case Exile.Path.parse(path) do
        [{:type, _root}] ->
          row = Exile.Record.row(record)
          true = :ets.insert_new(state.table_name, row)
          {id, ts, body} = row

          Logger.debug(
            "#{log_prefix()} [POST] Inserted #{id} @ #{ts} @ #{path} with #{inspect(body)}."
          )

          {:ok, id}

        [{:type, _}, {:id, _}] ->
          # Cannot create item on an attribute with POST
          {:error, :unsupported_operation}

        [{:type, _root}, {:id, id} | accessors] ->
          # Read the root record
          case get_root_record_by_id(path, id) do
            {:ok, root_parent} ->
              # Try to insert value into target path
              case insert_value(root_parent, accessors, record) do
                {:ok, updated_parent, nested_row} ->
                  # Insert updated parent row
                  :ets.insert(state.table_name, updated_parent)

                  # Note: nested rows are maps
                  %{id: id, ts: ts, value: body} = nested_row

                  Logger.debug(
                    "#{log_prefix()} [POST] Inserted #{id} @ #{ts} @ #{path} with #{inspect(body)}"
                  )

                  {:ok, id}

                err ->
                  err
              end

            err ->
              err
          end

        other_path ->
          {:error, :unsupported_operation}
      end

    {:reply, res, state}
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

  defp row_to_record({id, ts, value}) do
    %{
      id: id,
      ts: ts,
      value: value
    }
  end

  defp get_root_record_by_id(path, id, opts \\ :newest) do
    rows =
      path
      |> table_name_for_path!()
      |> :ets.lookup(id)

    case rows do
      [] ->
        {:error, :not_found}

      [row] ->
        {:ok, row_to_record(row)}

      rows ->
        case opts do
          :newest ->
            # We only want the one with the latest TS
            newest =
              rows
              |> Enum.sort_by(&elem(&1, 1), &>=/2)
              |> hd()
              |> row_to_record()

            {:ok, newest}

          :all ->
            # TODO When time travel options implemented this is done here
            all_revisions =
              rows
              |> Enum.sort_by(&elem(&1, 1), &>=/2)
              |> Enum.map(&row_to_record/1)

            {:ok, all_revisions}
        end
    end
  end

  def access_value(record, accessors) do
    do_access_value(record.value, accessors)
  end

  def do_access_value(value, []) do
    {:ok, value}
  end

  def do_access_value(value, [{:type, type} | rest]) when is_map(value) do
    value
    |> Map.get(type)
    |> do_access_value(rest)
  end

  def do_access_value(value, [{:id, _id} | _rest]) when is_map(value) do
    raise "Access Error: Cannot access map by id"
  end

  def do_access_value([%{id: _} | _] = value, [{:id, id} | rest]) when is_list(value) do
    case Enum.filter(value, &(&1.id == id)) do
      [item] ->
        item.value
        |> do_access_value(rest)

      _ ->
        :not_found
    end
  end

  def do_access_value(value, [{:type, _type} | _rest]) when is_list(value) do
    raise "Access Error: Cannot access list by type"
  end

  def do_access_value(value, [{:type, _type}]) when is_number(value) or is_binary(value) do
    value
  end

  def do_access_value(value, [{:type, type}]) when is_map(value) do
    Map.get(value, type)
  end

  ##
  # INSERTS
  ##

  def insert_value(record, [{:type, type}] = _accessors, new_value) do
    # TODO walk the path to the value
    access_path = [type]
    value = get_in(record.value, access_path)

    # Check it is a list
    case is_list(value) do
      true ->
        # Add item
        new_row_item = Exile.Record.row(new_value) |> row_to_record()
        updated_list = [new_row_item | value]
        new_record = put_in(record, [:value | access_path], updated_list)

        # Return updated record
        {:ok, Exile.Record.updated_row(new_record), new_row_item}

      false ->
        # When target is not a list, cannot add to it
        {:error, :unsupported_operation}
    end
  end
end
