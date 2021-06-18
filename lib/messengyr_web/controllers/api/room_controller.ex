defmodule MessengyrWeb.RoomController do
  use MessengyrWeb, :controller
  alias Messengyr.Chat
  alias MessengyrWeb.ErrorView

  plug Guardian.Plug.EnsureAuthenticated, error_handler: __MODULE__

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> render(ErrorView, "error.json", message: "You are not authenticated.")
  end

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    rooms = Chat.list_user_rooms(user)

    render(conn, "index.json", %{
      rooms: rooms,
      me: user,
    })
  end

  def create(conn, %{"counterpartUsername" => counterpart_username}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, room} <- Chat.create_room_with_counterpart(user, counterpart_username) do
      render(conn, "show.json", %{
        room: room,
        me: user,
      })
    end
  end

end
