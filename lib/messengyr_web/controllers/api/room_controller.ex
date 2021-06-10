defmodule MessengyrWeb.RoomController do
  use MessengyrWeb, :controller
  alias Messengyr.Chat

  def index(conn, _params) do
    rooms = Chat.list_rooms
    render(conn, "index.json", rooms: rooms)
  end
end
