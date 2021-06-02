defmodule MessengyrWeb.ChatController do
  use MessengyrWeb,
      :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params) do
    render conn
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:error, "You need to log in to view your messages.")
    |> redirect(to: "/")
  end

end
