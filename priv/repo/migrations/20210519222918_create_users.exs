defmodule Messengyr.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :usarname, :string
      add :email, :string
      add :encrypted_password, :string

      timestamps()
    end

    create unique_index(:users, [:usarname])
    create unique_index(:users, [:email])
  end
end
