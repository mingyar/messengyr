defmodule MessengyrWeb.MessageView do
  use MessengyrWeb, :view

  def message_json(message, %{me: me}) do
    IO.inspect me

    %{
      id: message.id,
      text: message.text,
      sentAt: message.inserted_at,
    }
  end
end
