# [GH#53] Timing attack in login authentication

**Severity:** HIGH
**Commit scope:** `lib/messengyr/accounts/session.ex`

## Problem

`Session.check_password/2` returns immediately when a username doesn't exist
(no bcrypt call), but takes ~ms when it does (bcrypt verification). This lets
attackers enumerate valid usernames by measuring response times:

```elixir
defp check_password(nil, _given_password) do
  {:error, "No user with this username was found!"}  # ← instant return
end

defp check_password(%{encrypted_password: pw} = user, given_password) do
  case Bcrypt.verify_pass(given_password, pw) do      # ← ~ms delay
    true -> {:ok, user}
    _ -> {:error, "Incorrect password"}
  end
end
```

Additionally, the error messages themselves reveal whether the username exists:
"No user with this username was found!" vs "Incorrect password".

## Fix Plan

### Step 1: Replace `lib/messengyr/accounts/session.ex`

```elixir
defmodule Messengyr.Accounts.Session do
  alias Messengyr.Accounts.User
  alias Messengyr.Repo

  def authenticate(%{"username" => username, "password" => given_password}) do
    user = Repo.get_by(User, username: username)
    check_password(user, given_password)
  end

  defp check_password(nil, given_password) do
    Bcrypt.no_user_verify()
    {:error, "Invalid username or password"}
  end

  defp check_password(%{encrypted_password: encrypted_password} = user, given_password) do
    case Bcrypt.verify_pass(given_password, encrypted_password) do
      true -> {:ok, user}
      _ -> {:error, "Invalid username or password"}
    end
  end
end
```

Two changes:
1. `Bcrypt.no_user_verify()` added — runs a dummy bcrypt verification that takes
   the same amount of time as a real one (prevents timing side-channel)
2. Error messages unified to `"Invalid username or password"` — attacker cannot
   distinguish "wrong password" from "no such user"

`Bcrypt.no_user_verify/0` is part of `bcrypt_elixir ~> 3.3` (already a dependency).

## Verification

1. `mix test` — existing `AccountsTest` still passes
2. In `iex -S mix`:
   ```elixir
   # Non-existent user — same error as wrong password
   Session.authenticate(%{"username" => "nobody", "password" => "x"})
   # => {:error, "Invalid username or password"}

   # Wrong password for existing user — same error
   Session.authenticate(%{"username" => "mingyar", "password" => "wrong"})
   # => {:error, "Invalid username or password"}

   # Valid login still works
   Session.authenticate(%{"username" => "mingyar", "password" => "pa55w0rd"})
   # => {:ok, %User{}}
   ```
3. Login form on the site: wrong credentials show "Invalid username or password"
   flash message regardless of whether the username exists.
