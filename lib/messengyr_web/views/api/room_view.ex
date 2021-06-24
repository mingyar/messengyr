defmodule MessengyrWeb.RoomView do
  @moduledoc """
  Renders Room structs in a given format.
  """
  use MessengyrWeb, :view

  import MessengyrWeb.MessageView, only: [message_json: 2]
  import MessengyrWeb.UserView, only: [user_jason: 1]

  @doc """
  Renders one or multiple Rooms in JSON format.

  ## Parameters

    - *template*: either `"show.json"` (for one) or `"index.json"` (for multiple)
    - *assigns*: a map that must contain the following keys-value pairs:
    - `:room` (or `:rooms`) => one or multiple `Room` structs
    - `:me` => a `User` struct
  """
  def render("show.json", %{room: room, me: me}) do
    %{
      room: room_json(room, %{me: me})
    }
  end

  def render("index.json", %{rooms: rooms, me: me}) do
    %{
      rooms: Enum.map(rooms, fn(room) -> room_json(room, %{me: me}) end)
    }
  end

  defp room_json(%{users: room_users} = room, %{me: me}) do
    counterpart = get_counterpart(room_users, me)
    %{
      id: room.id,
      counterpart: user_jason(counterpart),
      messages: Enum.map(room.messages, fn(message) -> message_json(message, %{me: me}) end),
      createdAt: room.inserted_at,
    }
  end

  defp get_counterpart(users, me) do
    Enum.find(users, fn(user) -> user.id != me.id end)
  end

end
