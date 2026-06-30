# [GH#55] Guardian typo: `allowoed_drift` → `allowed_drift`

**Severity:** HIGH
**Commit scope:** `config/config.exs`

## Problem

The Guardian config in `config/config.exs` has a typo:

```elixir
allowoed_drift: 2000,
```

The correct key is `allowed_drift` (double 'l'). Guardian silently ignores
unknown config keys, so the clock drift tolerance is effectively 0 ms. This
causes intermittent authentication failures when the server clock and the
token-issuer clock are slightly out of sync.

## Fix Plan

### Step 1: Fix the typo in `config/config.exs`

```diff
-   allowoed_drift: 2000,
+   allowed_drift: 2000,
```

### Important note

If you have already applied **Issue 01** (which moves Guardian config to
env-specific files), this typo is already fixed as part of that change.
In that case, skip this commit.

## Verification

1. `mix test` — all tests pass
2. No visible behaviour change — the 2000 ms drift tolerance now actually applies
3. If you previously saw intermittent "token expired" errors in test/dev, they
   should now be resolved
