defmodule Exile.Record do
  @moduledoc """
  Exile record stored at an `Exile.Path` that is JSON serialisable.
  """

  @typedoc """
  JSON Serialisable Record
  """
  @type t() :: map() | list() | String.t() | number()

  @typedoc """
  Timestamp in nanoseconds
  """
  @type timestamp :: pos_integer()

  @typedoc """
  Tuple for storage of a row
  """
  @type row() :: {Exile.Id.t(), timestamp(), t()}

  def row(record) do
    {
      Exile.Id.generate(),
      :erlang.system_time(:nanosecond),
      record
    }
  end
end
