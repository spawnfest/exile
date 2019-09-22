# TODO I have not figured out how to keep this file located here and still have
# it run against Exile.Repo
# SHOULD THIS STAY HERE OR STAY IN THE REPOS IN THE exile APP?
defmodule Exile.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password_hash, :string
      add :permissions, :map
      add :username, :string

      timestamps()
    end

  end
end
