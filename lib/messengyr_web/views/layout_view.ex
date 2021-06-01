defmodule MessengyrWeb.LayoutView do
  use MessengyrWeb, :view

  def logged_in?(conn) do
    Guardian.Plug.authenticated?(conn, [])
  end
end
