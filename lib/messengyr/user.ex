defmodule Messengyr.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string, unique: true
    field :encrypted_password, :string
    field :usarname, :string, unique: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:usarname, :email, :encrypted_password])
    |> validate_required([:usarname, :email, :encrypted_password])
  end
end
