# [GH#46] Password minimum length is only 4 characters

**Severity:** MEDIUM
**Commit scope:** `lib/messengyr/accounts/accounts.ex`

## Problem

`Accounts.register_changeset/1` enforces a 4-character minimum on passwords:

```elixir
|> validate_length(:password, min: 4)
```

With only lowercase letters, a 4-char password has ~457k possible values —
trivially bruteforceable in seconds. Industry standard minimum is 8 characters.

## Fix Plan

### Step 1: Increase minimum length in `accounts.ex`

```diff
-  |> validate_length(:password, min: 4)
+  |> validate_length(:password, min: 8)
```

### Step 2: Check existing tests

The test file `test/messengyr/accounts/accounts_test.exs` uses `"pa55w0rd"`
(8 chars) for valid-data tests and doesn't test the minimum-length boundary,
so no test changes are needed.

## Verification

1. `mix test` — all tests pass
2. In the signup form: a 4-char password shows a validation error
3. In the signup form: an 8+ char password succeeds
