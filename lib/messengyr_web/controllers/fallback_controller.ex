defmodule MessengyrWeb.FallbackController do
  use MessengyrWeb, :controller

  alias MessengyrWeb.ErrorView

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("error.json", message: "The resource couldn't be found!")
  end

  def call(conn, :not_allowed) do
    conn
    |> put_status(403)
    |> put_view(ErrorView)
    |> render("error.json", message: "You're not allowed to access this resource")
  end
end
