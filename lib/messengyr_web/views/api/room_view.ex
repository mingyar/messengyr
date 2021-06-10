defmodule MessengyrWeb.RoomView do
  use MessengyrWeb, :view

  import MessengyrWeb.MessageView, only: [message_json: 2]

  def render("index.json", %{rooms: rooms, me: me}) do
    %{
      rooms: Enum.map(rooms, fn(room) -> room_json(room, %{me: me}) end)
    }
  end

  defp room_json(room, %{me: me}) do
    %{
      id: room.id,
      messages: Enum.map(room.messages, fn(message) -> message_json(message, %{me: me}) end),
    }
  end
end
