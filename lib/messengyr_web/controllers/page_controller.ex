defmodule MessengyrWeb.PageController do
  use MessengyrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
