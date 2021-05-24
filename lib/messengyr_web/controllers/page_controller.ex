defmodule MessengyrWeb.PageController do
  use MessengyrWeb, :controller
  alias Messengyr.Accounts

  def index(conn, _params) do
    render conn
  end

  def login(conn, _params) do
    render conn
  end

  def signup(conn, _params) do
    changeset = Accounts.register_changeset()

    render conn, user_changeset: changeset
  end

  def create_user(conn, %{"user" => user_params}) do

    case Accounts.create_user(user_params) do

      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created succesfully")
        |> redirect(to: "/")

      {:error, user_changeset} ->
        conn
        |> put_flash(:error, "Unable to create account!")
        |> render("signup.html", user_changeset: user_changeset)

    end
  end

end
