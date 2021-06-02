defmodule MessengyrWeb.LayoutView do
  use MessengyrWeb, :view

  def logged_in?(conn) do
    Guardian.Plug.authenticated?(conn, [])
  end

  def username(conn) do
    user = Guardian.Plug.current_resource(conn)
    %{username: username} = user

    username
  end

  def avatar(conn) do
    user = Guardian.Plug.current_resource(conn)

    %{email: email} = user

    hash_email = :crypto.hash(:md5, email) |> Base.encode16 |> String.downcase

    "http://www.gravatar.com/avatar/#{hash_email}"
  end
end
