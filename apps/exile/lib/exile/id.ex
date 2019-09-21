defmodule Exile.Id do
  @moduledoc """
  Exile IDs generated to uniquely identify `Exile.Record` entries in collections.
  """

  @typedoc """
  Exile ID is a hex-encoded UUID string.
  """
  @type t :: Ecto.UUID.t()

  @spec generate :: t()
  def generate(), do: Ecto.UUID.generate()
end
