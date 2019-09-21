defmodule Exile.Record do
  @moduledoc """
  Exile record stored at an `Exile.Path` that is JSON serialisable.
  """

  @typedoc """
  JSON Serialisable Record
  """
  @type t() :: map() | list() | String.t() | number()
end
