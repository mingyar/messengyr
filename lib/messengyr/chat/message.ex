defmodule Messengyr.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Messengyr.Chat.Room
  alias Messengyr.Accounts.User

  schema "messages" do
    field :text, :string

    belongs_to :room, Room
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
