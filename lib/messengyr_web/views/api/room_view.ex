defmodule MessengyrWeb.RoomView do
  use MessengyrWeb, :view

  import MessengyrWeb.MessageView, only: [message_json: 1]

  def render("index.json", %{rooms: rooms}) do
    %{
      rooms: Enum.map(rooms, fn(room) -> room_json(room) end)
    }
  end

  defp room_json(room) do
    %{
      id: room.id,
      messages: Enum.map(room.messages, fn(message) -> message_json(message) end),
    }
  end
end
