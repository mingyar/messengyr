defmodule MessengyrWeb.MessageView do
  use MessengyrWeb, :view

  def render("show.json", %{message: message, me: me}) do
    %{
      message: message_json(message, %{me: me})
    }
  end

  def message_json(message, %{me: me}) do
    %{
      id: message.id,
      text: message.text,
      outgoing: outgoing?(message, me),
      sentAt: message.inserted_at,
    }
  end

  def outgoing?(message, me) do
    message.user_id == me.id
  end
end
