defmodule MessengyrWeb.ChatView do
  use MessengyrWeb, :view

  def jwt(conn) do
    Guardian.Plug.current_token(conn)
  end
end
