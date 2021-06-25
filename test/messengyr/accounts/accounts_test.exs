defmodule Messengyr.AccountsTest do
  use Messengyr.DataCase
  alias Messengyr.Accounts
  alias Messengyr.Accounts.User

  test "create_user/1 with missing data returns error changeset" do
    params = %{
      "username" => "mingyar",
      "password" => "pa55w0rd",
    }

    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(params)
  end

  test "create_user/1 with valid data creates a user" do
    params = %{
      "username" => "mingyar",
      "password" => "pa55w0rd",
      "email" => "mingyar.furtado@gmail.com",
    }

    assert {:ok, %User{}} = Accounts.create_user(params)
  end
end
