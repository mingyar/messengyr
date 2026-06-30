# [GH#58] Swap Guardian for Joken

**Severity:** LOW (improvement, not vulnerability)
**Depends on:** All priority-critical and priority-high fixes first (GH#50–GH#55)

## Context

Guardian 2.x is in maintenance mode and over-engineered for this app's needs.
It requires 3 modules (`Guardian`, `Pipeline`, `ApiPipeline`) + config in 4 files
+ 6 plug call patterns spread across controllers, views, socket, and router.

Joken does the same job in ~15 lines of code with no pipeline plumbing.

## Scope

**11 files** need changes, **3 files** can be deleted, **1 new file** created.

### Files to DELETE (3)

| File | Reason |
|------|--------|
| `lib/messengyr/auth/guardian.ex` | Replaced by Joken helper module |
| `lib/messengyr/auth/pipeline.ex` | No more Guardian.Plug.Pipeline |
| `lib/messengyr/auth/api_pipeline.ex` | No more Guardian.Plug.Pipeline |

### Files to CREATE (1)

| File | Purpose |
|------|---------|
| `lib/messengyr/auth/joken.ex` | `sign/1`, `verify/1`, `load_user/1` — the entire auth interface |

### Files to MODIFY (8)

| File | What changes |
|------|-------------|
| `config/config.exs` | Remove Guardian config (already done in GH#50) |
| `config/dev.exs` | Replace Guardian config with Joken config |
| `config/test.exs` | Same |
| `config/prod.exs` | Same |
| `lib/messengyr_web/router.ex` | Remove Guardian pipeline plugs, add custom session auth plug |
| `lib/messengyr_web/controllers/page_controller.ex` | Replace `Guardian.Plug.sign_in/2` → `Auth.Joken.sign/1`, `sign_out` → `clear_session` |
| `lib/messengyr_web/channels/user_socket.ex` | Replace `Guardian.decode_and_verify/1` → `Auth.Joken.verify/1` |
| `lib/messengyr_web/views/chat_view.ex` | Replace `Guardian.Plug.current_token/1` → read JWT from session |
| `lib/messengyr_web/views/layout_view.ex` | Replace `Guardian.Plug.authenticated?/2` + `current_resource/1` with session checks |
| `lib/messengyr_web/controllers/api/room_controller.ex` | Replace `Guardian.Plug.EnsureAuthenticated` + `current_resource/1` with custom plug |
| `lib/messengyr_web/controllers/api/message_controller.ex` | Replace `Guardian.Plug.current_resource(conn)` with custom plug |
| `lib/messengyr_web/controllers/chat_controller.ex` | Replace `Guardian.Plug.EnsureAuthenticated` with custom plug |

## Design

### New Auth module (`lib/messengyr/auth/joken.ex`)

```elixir
defmodule Messengyr.Auth.Token do
  # Sign a user → return JWT
  def sign(user), do: ...

  # Verify JWT → return user
  def verify(jwt), do: ...
end
```

Two functions. No pipelines, no plugs config, no error handlers.
Controllers use a simple `plug :authenticate` function plug.

### New session management

Instead of Guardian's cookie pipeline:
- On login: generate JWT, store in session and return to client
- On logout: clear session
- Browser: use `get_session(conn, :jwt)` to read
- API: use `Authorization: Bearer <jwt>` header
- `MessengyrWeb.Plugs.Authenticate` — reads JWT from session or header, loads user into `conn.assigns.current_user`

### Delete the pipeline modules

`guardian.ex`, `pipeline.ex`, `api_pipeline.ex` — all gone.
The router goes from:
```elixir
pipeline :browser do
  plug Guardian.Plug.Pipeline, ...
end
pipeline :browser_session do
  plug Messengyr.Auth.Pipeline
end
```
To:
```elixir
pipeline :auth do
  plug MessengyrWeb.Plugs.Authenticate
end
```

## Prerequisites

All of these must be fixed **before** this swap:

- [ ] GH#50 — Hardcoded Guardian secret (done)
- [ ] GH#51 — Hardcoded secret_key_base
- [ ] GH#52 — Unauthenticated user API
- [ ] GH#53 — Timing attack in login
- [ ] GH#54 — Unquoted img src
- [ ] GH#55 — Guardian allowed_drift typo
- [ ] GH#44 — Repo.get_by! raises on missing user
- [ ] Full test coverage for auth flows (no tests currently exist for login/logout/token verification)

## Migration strategy

One single commit. The app will be broken mid-swap, so this must be done atomically:

1. Add `joken` to `mix.exs`
2. Create `lib/messengyr/auth/token.ex`
3. Create `lib/messengyr_web/plugs/authenticate.ex`
4. Update `router.ex`
5. Update all controllers, views, socket
6. Delete old pipeline modules
7. Remove Guardian from `mix.exs`
8. Update config files
9. `mix test` — must be green

## Verification

1. `mix test` — all tests pass
2. Login → get redirected to `/messages` with session
3. API: `POST /api/rooms` with Bearer token works
4. WebSocket connects with `guardianToken` param
5. Logout clears session
6. Unauthenticated requests get 401/redirect
