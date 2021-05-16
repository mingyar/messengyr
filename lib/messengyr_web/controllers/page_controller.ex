defmodule MessengyrWeb.PageController do
  use MessengyrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def say_hello(conn, _params) do
    text conn, "Hello!"
  end
end
