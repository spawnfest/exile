defmodule Exile.Path do
  @moduledoc """
  Resource Locator Path pointing to `Exile.Record`.
  """

  @typedoc """
  A path to a record e.g.
  	"/posts" points to the posts records
  	"/posts/$post_id" points to a specific post record
  	"/posts/$post_id/author" points to the author of a specific post
  """
  @type t() :: String.t()

  @typedoc "Type name in path."
  @type type :: String.t()

  @typedoc "Id pointing to record in path."
  @type id :: Exile.Id.t()

  @type parsed_path :: [{:root, type, id} | {:type, type} | {:id, id}]

  @delim "/"

  @doc """
  Creates a references used to locate store for items
  within a given path.
  """
  def to_ref(path) do
    # We are going to use the path root as the reference.
    # Which means there will be 1 table per root level item.
    # We can change this to add scoping later during prototype.
    root(path)
  end

  @doc "Parses path categorising each section into `type` or `id`."
  def parse(path) do
    path
    |> String.split(@delim)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn value ->
      if Exile.Id.is_id?(value) do
        {:id, value}
      else
        {:type, value}
      end
    end)
  end

  @doc "Computes the root of a path"
  def root(path) do
    path
    |> String.split(@delim)
    |> Enum.filter(&(&1 != ""))
    |> hd()
  end
end
