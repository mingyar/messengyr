# [GH#54] Unquoted `<img src>` in layout template

**Severity:** HIGH
**Commit scope:** `lib/messengyr_web/templates/layout/header.html.eex`

## Problem

The avatar `<img>` tag in the header template has an unquoted `src` attribute:

```eex
<img src=<%= avatar(@conn) %> />
```

HTML allows omitting quotes around attribute values only if the value contains
no spaces or special characters. If the `avatar/1` function ever returns a value
with spaces (e.g., a URL with query parameters, or if the email hash format
changes), the browser interprets the space as an attribute separator. This is
an HTML injection vector.

Currently `avatar/1` returns `"http://www.gravatar.com/avatar/<hex>"` which
happens to have no spaces, but relying on that is fragile and violates
defense-in-depth.

## Fix Plan

### Step 1: Add quotes to `src` attribute in `header.html.eex`

```diff
- <img src=<%= avatar(@conn) %> />
+ <img src="<%= avatar(@conn) %>" />
```

## Verification

1. `mix test` — all tests pass
2. Load any page in the browser — avatar image displays correctly
3. View page source — `<img>` tag has properly quoted `src=""`
