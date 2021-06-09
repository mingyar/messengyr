defmodule Messengyr.Chat.RoomUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "room_users" do

    timestamps()
  end

  @doc false
  def changeset(room_user, attrs) do
    room_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
