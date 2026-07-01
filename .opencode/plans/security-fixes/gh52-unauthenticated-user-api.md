# [GH#52] Unauthenticated `GET /api/user/:id`

**Severity:** HIGH
**Commit scope:** `lib/messengyr_web/controllers/api/user_controller.ex`

## Problem

`UserController` has no authentication check. The `:api` pipeline uses
`Guardian.Plug.LoadResource, allow_blank: true` which does **not** reject
unauthenticated requests — it just leaves `current_resource` as `nil` and
continues. Since `UserController` never calls `EnsureAuthenticated`, any
client can enumerate all users by ID:

```bash
curl http://localhost:4000/api/user/1   # returns user data (no token needed)
curl http://localhost:4000/api/user/2   # returns user data
```

Compare with `RoomController` which uses the correct pattern:

```elixir
plug Guardian.Plug.EnsureAuthenticated, error_handler: __MODULE__
```

## Fix Plan

### Step 1: Add auth plug to `UserController`

Replace the full file content with:

```elixir
defmodule MessengyrWeb.UserController do
  use MessengyrWeb, :controller
  alias Messengyr.Accounts
  alias MessengyrWeb.ErrorView

  plug Guardian.Plug.EnsureAuthenticated, error_handler: __MODULE__

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> put_view(ErrorView)
    |> render("error.json", message: "You are not authenticated.")
  end

  action_fallback MessengyrWeb.FallbackController

  def show(conn, %{"id" => user_id}) do
    user = user_id |> Accounts.get_user()

    if user do
      conn |> render("show.json", user: user)
    end
  end
end
```

Three additions:
1. `alias MessengyrWeb.ErrorView`
2. `plug Guardian.Plug.EnsureAuthenticated, error_handler: __MODULE__`
3. `auth_error/3` returning 401 JSON

## Verification

1. `mix test` — all tests pass
2. Without token — `curl -v http://localhost:4000/api/user/1` returns `401`
3. With valid Bearer token — `curl -v -H "Authorization: Bearer <jwt>" http://localhost:4000/api/user/1` returns `200`
