defmodule Messengyr.GuardianConfigTest do
  use ExUnit.Case, async: true

  test "Guardian secret key is not the hardcoded weak default" do
    secret_key = Application.get_env(:messengyr, Messengyr.Auth.Guardian, [])[:secret_key]

    refute secret_key == "5ecret_k3y",
           "Guardian secret key must not be the well-known weak value '5ecret_k3y'. " <>
             "Set GUARDIAN_SECRET_KEY env var or use a secure dev fallback."
  end
end
