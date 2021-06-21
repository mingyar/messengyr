defmodule MessengyrWeb.RoomChannel do
  use MessengyrWeb, :channel

  @impl true
  def join("room:" <> room_id, _payload, socket) do
      {:ok, socket}
  end

end
