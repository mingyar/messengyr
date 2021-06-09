defmodule MessengyrWeb.UserController do
  use MessengyrWeb, :controller
  alias Messengyr.Accounts

  def show(conn, %{"id" => user_id}) do
    user = user_id |> Accounts.get_user

    conn |> render("show.json", user: user)
  end

end
