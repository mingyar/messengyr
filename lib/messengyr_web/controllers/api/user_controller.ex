defmodule MessengyrWeb.UserController do
  use MessengyrWeb, :controller
  alias Messengyr.Accounts

  action_fallback MessengyrWeb.FallbackController

  def show(conn, %{"id" => user_id}) do
    user = user_id |> Accounts.get_user

    if user do
      conn |> render("show.json", user: user)
    end

  end

end
