defmodule MessengyrWeb.UserView do
  use MessengyrWeb, :view

  def render("show.json", %{user: user}) do
    %{
      user: user_jason(user)
    }
  end

  def user_jason(user) do
    hash_email = :crypto.hash(:md5, user.email) |> Base.encode16 |> String.downcase
    avatar_url = "http://www.gravatar.com/avatar/#{hash_email}"

    %{
      id: user.id,
      username: user.username,
      avatarURL: avatar_url
    }
  end

end
