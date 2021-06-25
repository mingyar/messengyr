defmodule Messengyr.AccountsTest do
  use Messengyr.DataCase
  alias Messengyr.Accounts

  test "create_user/1 with missing data returns error changeset" do
    params = %{
      "username" => "mingyar",
      "password" => "pa55w0rd",
    }

    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(params)
  end
end
