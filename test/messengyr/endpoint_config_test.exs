defmodule Messengyr.EndpointConfigTest do
  use ExUnit.Case, async: true

  test "secret_key_base is not the hardcoded default" do
    secret_key_base =
      Application.get_env(:messengyr, MessengyrWeb.Endpoint, [])[:secret_key_base]

    refute secret_key_base ==
             "qWetP8ZBUJH0KWGM8Zqy9Ev48Nqi9i1RfH0fMknMLtxGCyQAjwKei7r+TO+QpuJ7",
           "secret_key_base must not be the well-known hardcoded value. " <>
             "Set SECRET_KEY_BASE env var or use a secure dev/test fallback."
  end
end
