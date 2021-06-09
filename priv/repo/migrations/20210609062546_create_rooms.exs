defmodule Messengyr.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do

      timestamps()
    end

  end
end
