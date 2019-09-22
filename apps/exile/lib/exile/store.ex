defmodule Exile.Store do
  @moduledoc """
  An interface to the storage subsystems that can be implemented
  to provide a tranlation layer for a different storage technology.

  The contract is enforced through the implementation of the behaviour
  and adherence to the specification and documented "behaviourial" characterists.
  """

  alias Exile.{Record, Id, Path, Subscriber}

  @typedoc "An `Exile.Store` Implementation"
  @type t() :: module()

  @callback get(Path.t()) :: {:ok, Record.t()} | {:error, Exile.get_error_reason()}
  @callback post(Path.t(), Record.t()) :: {:ok, Id.t()} | {:error, Exile.post_error_reason()}
  @callback put(Path.t(), Record.t()) :: :ok | {:error, Exile.put_error_reason()}
  @callback delete(Path.t()) :: {:ok, Record.t()} | {:error, Exile.delete_error_reason()}
  @callback subscribe(Path.t(), Subscriber.t()) :: :ok | {:error, Exile.subscribe_error_reason()}
  @callback unsubscribe(Path.t(), Subscriber.t()) ::
              :ok | {:error, Exile.unsubscribe_error_reason()}
  @callback child_specs() :: [Supervisor.child_spec()]

  @doc "Return the record(s) at the path."
  @spec get(t(), Path.t()) :: {:ok, Record.t()} | {:error, Exile.get_error_reason()}
  def get(store, path) do
    store.get(path)
  end

  @doc "Create record at path."
  @spec post(t(), Path.t(), Record.t()) ::
          {:ok, Id.t()} | {:error, Exile.post_error_reason()}
  def post(store, path, record) when is_atom(store) do
    store.post(path, record)
  end

  @doc "Update record at path."
  @spec put(t(), Path.t(), Record.t()) :: :ok | {:error, Exile.put_error_reason()}
  def put(store, path, record) when is_atom(store) do
    store.put(path, record)
  end

  @doc "Remove record at path."
  @spec delete(t(), Path.t()) :: {:ok, Record.t()} | {:error, Exile.delete_error_reason()}
  def delete(store, path) when is_atom(store) do
    store.get(path)
  end

  @doc "Subscribe to events at path."
  @spec subscribe(t(), Path.t(), Subscriber.t()) :: :ok | {:error, Exile.subscribe_error_reason()}
  def subscribe(store, path, subscriber) when is_atom(store) do
    store.subscribe(path, subscriber)
  end

  @doc "Unsubscribe from events at path."
  @spec unsubscribe(t(), Path.t(), Subscriber.t()) ::
          :ok | {:error, Exile.unsubscribe_error_reason()}
  def unsubscribe(store, path, subscriber) when is_atom(store) do
    store.unsubscribe(path, subscriber)
  end

  @doc "Child specifications of processes used in the storage implementation"
  @spec child_specs(t()) :: [Supervisor.child_spec()]
  def child_specs(store) do
    store.child_specs()
  end
end
