defmodule Messengyr.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
