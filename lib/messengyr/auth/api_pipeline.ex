defmodule Messengyr.Auth.ApiPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :messengyr,
    module: Messengyr.Auth.Guardian

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
