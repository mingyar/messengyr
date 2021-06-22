defmodule MessengyrWeb.RoomChannel do
  use MessengyrWeb, :channel
  alias Messengyr.Chat
  alias Messengyr.Chat.Room

  @impl true
  def join("room:" <> room_id, _payload, socket) do
    me = socket.assigns.current_user

    case Chat.get_room(room_id) do
      %Room{} = room ->
        if Chat.room_has_user?(room, me) do
          {:ok, socket}
        else
          {:error, %{reason: "You're not a member of this room!"}}
        end
      _ -> {:error, %{reason: "This room doesn't exist!"}}
    end
  end

  def handle_in("message:new", %{"text" => text, "room_id" => room_id}, socket) do
    me = socket.assigns.current_user
    room = Chat.get_room(room_id)

    with {:ok, message} <- Chat.add_message(%{
      room: room,
      user: me,
      text: text,
    }) do
      IO.puts "Added message!"

      json = %{
        messageId: message.id,
      }

      broadcast! socket, "message:new", json

      {:reply, :ok, socket}
    else
      _ -> {:error, %{reason: "Couldn't add message!"}}
    end
  end

end
