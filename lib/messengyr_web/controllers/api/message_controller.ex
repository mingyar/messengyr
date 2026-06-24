defmodule MessengyrWeb.MessageController do
  use MessengyrWeb, :controller

  alias Messengyr.Chat
  alias Messengyr.Chat.Message

  action_fallback MessengyrWeb.FallbackController

  def show(conn, %{"id" => message_id}) do
    me = Guardian.Plug.current_resource(conn)

    case Chat.get_message(message_id) do
      %Message{room: room} = message ->
        if Chat.room_has_user?(room, me) do
          render(conn, "show.json", %{message: message, me: me})
        else
          :not_allowed
        end

      _ ->
        nil
    end
  end
end
