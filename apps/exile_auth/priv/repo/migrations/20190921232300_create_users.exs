defmodule ExileAuth.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password_hash, :string
      add :permissions, :map
      add :username, :string

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
