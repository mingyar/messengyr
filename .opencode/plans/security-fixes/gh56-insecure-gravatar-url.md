# [GH#56] Gravatar URL uses HTTP instead of HTTPS

**Severity:** MEDIUM
**Commit scope:** `lib/messengyr_web/views/layout_view.ex`, `lib/messengyr_web/views/api/user_view.ex`

## Problem

Two files construct Gravatar avatar URLs using `http://`:

- `lib/messengyr_web/views/layout_view.ex` line 22
- `lib/messengyr_web/views/api/user_view.ex` line 35

```elixir
"http://www.gravatar.com/avatar/#{hash_email}"
```

The production site runs on HTTPS (`messengyr-app.herokuapp.com`). Loading
avatar images over HTTP triggers browser mixed-content warnings and may
block the images entirely depending on browser settings.

## Fix Plan

### Step 1: Fix `lib/messengyr_web/views/layout_view.ex`

```diff
-    "http://www.gravatar.com/avatar/#{hash_email}"
+    "https://www.gravatar.com/avatar/#{hash_email}"
```

### Step 2: Fix `lib/messengyr_web/views/api/user_view.ex`

Two occurrences — the code (line 35) and the doctest example (line 21):

```diff
-    avatar_url = "http://www.gravatar.com/avatar/#{hash_email}"
+    avatar_url = "https://www.gravatar.com/avatar/#{hash_email}"
```

```diff
-    avatarURL: "http://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0",
+    avatarURL: "https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0",
```

## Verification

1. `mix test` — `UserViewTest` runs doctests and should still pass
2. `mix phx.server` — load the app, check browser console for no mixed-content errors
