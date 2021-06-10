defmodule MessengyrWeb.RoomController do
  use MessengyrWeb, :controller
  alias Messengyr.Chat

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    rooms = Chat.list_rooms

    render(conn, "index.json", %{
      rooms: rooms,
      me: user,
    })
  end
end
