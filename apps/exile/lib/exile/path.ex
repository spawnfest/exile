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

  @delim "/"

  @doc """
  Creates a references used to locate store for items
  within a given path.

  The initial strategy will be to use the root of the path
  provided, this can be expanded on as desired.
  """
  def to_ref(path) do
    case String.split(path, @delim) do
      ["", root | _] -> root
      [root | _] -> root
    end
  end
end
