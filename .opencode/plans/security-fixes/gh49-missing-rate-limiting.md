# [GH#49] No rate limiting on login endpoint

**Severity:** LOW
**Commit scope:** `mix.exs`, `config/config.exs`, `lib/messengyr_web/plugs/rate_limit.ex` (new), `lib/messengyr_web/router.ex`

## Problem

The login endpoint (`POST /login`) has no rate limiting. An attacker can
brute-force passwords or flood the endpoint with unlimited requests. Even
with the timing-attack fix (Issue 04), unlimited password attempts are still
possible.

## Fix Plan

### Step 1: Add `hammer` dependency to `mix.exs`

```elixir
{:hammer, "~> 6.0"},
```

### Step 2: Configure Hammer in `config/config.exs`

```elixir
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000, cleanup_interval_ms: 60_000]}
```

ETS backend is in-memory — no external dependency needed.

### Step 3: Create `lib/messengyr_web/plugs/rate_limit.ex`

```elixir
defmodule MessengyrWeb.Plugs.RateLimit do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")

    case Hammer.check_rate("login:#{ip}", 60_000, 5) do
      {:allow, _count} ->
        conn

      {:deny, _count} ->
        conn
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.put_view(MessengyrWeb.ErrorView)
        |> Phoenix.Controller.render("error.json", message: "Too many requests. Try again later.")
        |> halt()
    end
  end
end
```

Rate limit: **5 requests per 60 seconds per IP**.

### Step 4: Add plug to the browser pipeline in `router.ex`

```elixir
pipeline :browser do
  ...
  plug :put_secure_browser_headers
  plug MessengyrWeb.Plugs.RateLimit    # ← add before Guardian
  plug Guardian.Plug.Pipeline, ...
end
```

Placing it before Guardian means rate limiting applies before any bcrypt
work is done — no wasted CPU on throttled requests.

## Verification

1. `mix deps.get && mix test` — all tests pass
2. Send 6 rapid `POST /login` requests from the same IP — the 6th gets `429`
3. Wait 60 seconds — rate limit resets, requests work again
