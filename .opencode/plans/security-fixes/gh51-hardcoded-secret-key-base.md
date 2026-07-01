# [GH#51] Hardcoded `secret_key_base`

**Severity:** CRITICAL
**Commit scope:** `config/config.exs`, `config/dev.exs`, `config/test.exs`

## Problem

The Phoenix `secret_key_base` is hardcoded in `config/config.exs`:

```elixir
secret_key_base: "qWetP8ZBUJH0KWGM8Zqy9Ev48Nqi9i1RfH0fMknMLtxGCyQAjwKei7r+TO+QpuJ7",
```

This key signs session cookies and CSRF tokens. Anyone with repo access can:
- Forge valid session cookies
- Bypass CSRF protection
- Decrypt signed session data

Production overrides this via `SECRET_KEY_BASE` env var, but dev and test
environments use the fixed value from source control.

## Fix Plan

### Step 1: Change `config/config.exs` to read from env var

```diff
-  secret_key_base: "qWetP8ZBUJH0KWGM8Zqy9Ev48Nqi9i1RfH0fMknMLtxGCyQAjwKei7r+TO+QpuJ7",
+  secret_key_base: System.get_env("SECRET_KEY_BASE"),
```

### Step 2: Add dev fallback in `config/dev.exs`

```elixir
config :messengyr, MessengyrWeb.Endpoint,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") || "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
```

### Step 3: Add test fallback in `config/test.exs`

```elixir
config :messengyr, MessengyrWeb.Endpoint,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") || "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
```

### Step 4: Confirm `config/prod.exs` is unchanged

It already reads from env var:

```elixir
secret_key_base: System.get_env("SECRET_KEY_BASE")
```

No change needed.

## Verification

1. `mix test` — all tests pass
2. `mix phx.server` — app boots, login/session flow works
3. `curl -v http://localhost:4000/` — returns 200, cookies set correctly
