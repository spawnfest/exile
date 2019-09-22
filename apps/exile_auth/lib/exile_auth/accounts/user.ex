defmodule ExileAuth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :password_hash, :string
    field :permissions, :map
    field :username, :string

    # Virtual attribute for holding plaintext passwords
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :permissions, :password])
    |> validate_required([:username, :password]) # TODO ignoring permissions for now
    |> validate_length(:username, min: 3, max: 64)
    |> validate_length(:password, min: 10)
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        change(changeset, Bcrypt.add_hash(password))
      _ ->
        changeset
    end
  end
end
