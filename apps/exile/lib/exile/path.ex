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
end
