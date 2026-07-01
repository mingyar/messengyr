# [GH#50] Hardcoded Guardian JWT secret key

**Severity:** CRITICAL
**Commit scope:** `config/config.exs`, `config/dev.exs`, `config/test.exs`, `config/prod.exs`

## Problem

The Guardian JWT signing key is hardcoded in `config/config.exs` as `"5ecret_k3y"` — a
trivially guessable value. Anyone with repo access can forge valid JWTs for any user
in dev and test environments. In production, if the `GUARDIAN_SECRET_KEY` env var is
ever missing (e.g., misconfigured deployment), the app silently falls back to this
weak key instead of failing to start.

Additionally, `allowoed_drift` is misspelled in the same config block — Guardian silently
ignores it, so JWT clock-drift tolerance is effectively 0 ms. This fix corrects the
spelling to `allowed_drift`.

## Fix Plan

### Step 1: Remove Guardian config from `config/config.exs`

Delete lines 40–44 (the entire Guardian config block):

```diff
- config :messengyr, Messengyr.Auth.Guardian,
-   issuer: "messengyr",
-   ttl: {30, :days},
-   allowoed_drift: 2000,
-   secret_key: "5ecret_k3y"
```

### Step 2: Add Guardian config to `config/dev.exs`

Append at end of file:

```elixir
config :messengyr, Messengyr.Auth.Guardian,
  issuer: "messengyr",
  ttl: {30, :days},
  allowed_drift: 2000,
  secret_key:
    System.get_env("GUARDIAN_SECRET_KEY") || "dev-only-insecure-key-do-not-use-in-prod"
```

### Step 3: Add Guardian config to `config/test.exs`

Append at end of file:

```elixir
config :messengyr, Messengyr.Auth.Guardian,
  issuer: "messengyr",
  ttl: {30, :days},
  allowed_drift: 2000,
  secret_key:
    System.get_env("GUARDIAN_SECRET_KEY") || "dev-only-insecure-key-do-not-use-in-prod"
```

### Step 4: Expand Guardian config in `config/prod.exs`

Replace the single-line config (line 29) with the full block:

```diff
- config :messengyr, Messengyr.Auth.Guardian, secret_key: System.get_env("GUARDIAN_SECRET_KEY")
+ config :messengyr, Messengyr.Auth.Guardian,
+   issuer: "messengyr",
+   ttl: {30, :days},
+   allowed_drift: 2000,
+   secret_key: System.get_env("GUARDIAN_SECRET_KEY")
```

The fallback strings in dev/test (`"dev-only-insecure-key-do-not-use-in-prod"`) are
intentionally different from the old hardcoded value to make it obvious if one leaks.

## Verification

1. `mix test` — all existing tests pass
2. `mix phx.server` — app starts and login flow works
3. Unset `GUARDIAN_SECRET_KEY` in dev — app still works using the dev fallback
4. Confirm `GUARDIAN_SECRET_KEY` is never printed in logs or error pages
