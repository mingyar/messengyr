defmodule Messengyr.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Messengyr.Chat.Message

  schema "rooms" do
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
