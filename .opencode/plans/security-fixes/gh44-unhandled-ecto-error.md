# [GH#44] `Repo.get_by!` raises on missing counterpart username

**Severity:** MEDIUM
**Commit scope:** `lib/messengyr/chat/chat.ex`, `lib/messengyr_web/controllers/api/room_controller.ex`

## Problem

`Chat.create_room_with_counterpart/2` uses `Repo.get_by!`:

```elixir
def create_room_with_counterpart(me, counterpart_username) do
  counterpart = Repo.get_by!(User, username: counterpart_username)
  ...
end
```

When the username doesn't exist, `Repo.get_by!` raises `Ecto.NoResultsError`,
causing a 500 Internal Server Error. This:

- Returns a 500 error instead of a proper 404
- Leaks stack traces in dev mode
- Also reveals username existence (valid usernames succeed, invalid ones crash)

## Fix Plan

### Step 1: Replace `Repo.get_by!` in `lib/messengyr/chat/chat.ex`

```elixir
def create_room_with_counterpart(me, counterpart_username) do
  case Repo.get_by(User, username: counterpart_username) do
    nil ->
      {:error, :user_not_found}

    counterpart ->
      members = [counterpart, me]

      with {:ok, room} <- create_room() do
        add_room_users(room, members)
      end
  end
end
```

### Step 2: Handle the new error tuple in `room_controller.ex`

Replace the `create` action:

```elixir
def create(conn, %{"counterpartUsername" => counterpart_username}) do
  user = Guardian.Plug.current_resource(conn)

  case Chat.create_room_with_counterpart(user, counterpart_username) do
    {:ok, room} ->
      render(conn, "show.json", %{room: room, me: user})

    {:error, :user_not_found} ->
      conn
      |> put_status(:not_found)
      |> put_view(MessengyrWeb.ErrorView)
      |> render("error.json", message: "User not found")
  end
end
```

## Verification

1. `mix test` — all tests pass
2. `POST /api/rooms` with a non-existent `counterpartUsername`:
   ```bash
   curl -X POST -H "Authorization: Bearer <jwt>" \
        -d "counterpartUsername=nobody" \
        http://localhost:4000/api/rooms
   ```
   Returns `404` with `{"error": {"message": "User not found"}}` — no crash.

3. `POST /api/rooms` with an existing username still succeeds.
