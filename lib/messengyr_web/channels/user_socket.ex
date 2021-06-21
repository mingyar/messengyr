defmodule MessengyrWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", MessengyrWeb.RoomChannel

  @impl true
  def connect(%{"guardianToken" => jwt}, socket) do
    with {:ok, claims} <- Messengyr.Auth.Guardian.decode_and_verify(jwt),
         {:ok, user} <- Messengyr.Auth.Guardian.resource_from_claims(claims)
    do
      {:ok, assign(socket, :current_user, user)}
    else
      _ -> :error
    end
  end

  def connect(_params, _socket) do
    :error
  end

  @impl true
  def id(_socket), do: nil
end
