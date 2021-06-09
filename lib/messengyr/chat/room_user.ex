defmodule Messengyr.Chat.RoomUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias Messengyr.Chat.Room
  alias Messengyr.Accounts.User

  schema "room_users" do
    belongs_to :room, Room
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(room_user, attrs) do
    room_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
