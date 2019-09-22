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

  @spec is_id?(t()) :: boolean()
  def is_id?(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
