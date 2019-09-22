defmodule Exile do
  @moduledoc """
  OTP Application which enables RESTful style record storage and access
  """
  import Exile.Config

  alias Exile.{Record, Id, Path, Store, Subscriber}

  @type get_error_reason :: :not_found
  @type post_error_reason :: :unsupported_operation
  @type put_error_reason :: :not_found
  @type delete_error_reason :: :not_found
  @type subscribe_error_reason :: :not_found | :not_implemented
  @type unsubscribe_error_reason :: :not_found | :not_implemented

  @doc "Return the record(s) at the path."
  @spec get(Path.t()) :: {:ok, Record.t()} | {:error, get_error_reason}
  def get(path) do
    Store.get(store(), path)
  end

  @doc "Create record at path."
  @spec post(Path.t(), Record.t()) ::
          {:ok, Id.t()} | {:error, post_error_reason}
  def post(path, record) do
    Store.post(store(), path, record)
  end

  @doc "Update record at path."
  @spec put(Path.t(), Record.t()) :: :ok | {:error, put_error_reason}
  def put(path, record) do
    Store.put(store(), path, record)
  end

  @doc "Remove record at path."
  @spec delete(Path.t()) :: {:ok, Record.t()} | {:error, delete_error_reason}
  def delete(path) do
    Store.delete(store(), path)
  end

  @doc "Subscribe to events at path."
  @spec subscribe(Path.t(), Subscriber.t()) :: :ok | {:error, subscribe_error_reason}
  def subscribe(path, subscriber \\ nil) do
    subscriber = subscriber || self()
    Store.subscribe(store(), path, subscriber)
  end

  @doc "Unsubscribe from events at path."
  @spec unsubscribe(Path.t(), Subscriber.t()) :: :ok | {:error, unsubscribe_error_reason}
  def unsubscribe(path, subscriber \\ nil) do
    subscriber = subscriber || self()
    Store.unsubscribe(store(), path, subscriber)
  end

  @doc "Child specifications of processes used by exile"
  @spec child_specs() :: [Supervisor.child_spec()]
  def child_specs() do
    Store.child_specs(store())
  end
end
