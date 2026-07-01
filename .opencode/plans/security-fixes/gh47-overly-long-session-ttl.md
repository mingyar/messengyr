# [GH#47] Session TTL is 30 days

**Severity:** LOW
**Commit scope:** `config/config.exs`

## Problem

Guardian tokens have a 30-day TTL:

```elixir
ttl: {30, :days},
```

If a JWT is stolen (XSS, leaked logs, MITM), the attacker has 30 days of
uninterrupted access. This app has no token-revocation mechanism (no
blacklist, no refresh-token rotation).

## Fix Plan

### Step 1: Reduce the TTL

```diff
-  ttl: {30, :days},
+  ttl: {7, :days},
```

For a chat app, 7 days is a reasonable balance between user convenience
and security. Users are logged out after a week of inactivity and must
re-authenticate.

### If Issue 01 was already applied

Make the same change in each environment file:
- `config/dev.exs`
- `config/test.exs`
- `config/prod.exs`

## Verification

1. `mix test` — all tests pass
2. Log in, decode the JWT at `jwt.io` — the `exp` claim should be ~7 days
   from `iat` (down from 30)
