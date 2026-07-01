# Messengyr — AGENTS.md

Facebook Messenger clone. **Phoenix 1.5.7** + **Phoenix Channels** + **React 16 SPA**.

**Not a LiveView app.** The `.opencode/agents/liveview-archtect.md` agent exists but its guidance is irrelevant here.

## Critical workflow

- **`mix precommit`** runs: `compile --warnings-as-errors` → `deps.unlock --unused` → `format` → `test`. Use this before every commit.

### Branch workflow (MANDATORY — never bypass)

0. **Always pull the latest `main` first.** Before starting work on any issue, fetch and pull the most recent copy of `main`:
   ```bash
   git checkout main && git pull origin main
   ```
1. **Create a feature branch first.** Never commit directly to `main`. Branch name convention: `fix/description` or `feat/description`.
2. **Implement on the branch.** All work happens there.
3. **Ask before every action** — each step requires explicit confirmation:
   - "Can I commit?" → wait for answer before running `git commit`
   - "Can I push?" → wait for answer before running `git push`
   - "Can I open a pull request?" → wait for answer before running `gh pr create`
4. **When opening a PR, assign the user as reviewer.** Use: `gh pr create --assignee @me` or assign the user specifically.
5. **After opening a PR, return to `main` and pull the latest.** Opening a PR means the job is finished — go back to a clean slate:
   ```bash
   git checkout main && git pull origin main
   ```
6. **After PR is merged, delete the remote branch and the local plan file for that issue.** This keeps `.opencode/plans/security-fixes/` in sync with what's actually left to do:
   ```bash
   git push origin --delete fix/branch-name
   rm .opencode/plans/security-fixes/gh<number>-*.md
   ```

### Security fix workflow (MANDATORY)

When fixing a security issue (or any bug), follow this process:

1. **Write a failing test first** — write a test that captures the vulnerability
2. **Run it to confirm** — it must fail, proving the bug exists
3. **Show the user** the failing test output
4. **Wait for user approval** before writing any fix code
5. **Implement the fix**
6. **The test now passes** — the vulnerability is closed
7. **Run `mix test`** — full suite is green, nothing regressed

Never skip step 1-4. Never jump to fix code before the user has seen the failing test.

### Never

- ❌ Commit directly to `main`
- ❌ Push without asking
- ❌ Open a PR without asking
- ❌ Merge your own PR

## Commands

| Command | Note |
|---------|------|
| `mix setup` | deps.get + ecto.create/migrate/seed + `npm install --prefix assets` |
| `mix test` | auto-creates+migrates test DB — no manual `ecto.setup` needed |
| `mix test path:42` | single line |
| `mix phx.server` | dev on :4000, webpack watcher included |
| `npm run deploy` | webpack production build (from `assets/`) |

- Only `mix format` for code quality. No linter, no typechecker.
- Formatter imports `[:ecto, :phoenix]` in `.formatter.exs`.

## Real-time (Channels, not LiveView)

- `UserSocket` at `/socket`. Auth via `guardianToken` param (JWT embedded in `window.jwtToken` in the chat template).
- `RoomChannel` handles `"room:*"` topics: join `"room:{id}"`, send `"message:new"`.
- Broadcasts use `broadcast!` inside the channel handler. No PubSub subscriptions outside channels.

## Auth (Guardian JWT + Bcrypt)

Two pipelines: **browser session** (`VerifySession`) and **API Bearer token** (`VerifyHeader`, realm `"Bearer"`).

Quirk: router pipeline plug references `Messengyr.Guardian` but the real module is `Messengyr.Auth.Guardian`. This compiles because Guardian resolves the alias internally.

Passwords: `bcrypt_elixir` via `Bcrypt.hash_pwd_salt/1` + `Bcrypt.verify_pass/2`.

## Frontend (React SPA)

- React 16 + Redux in `assets/js/`, webpack 4 bundler, SCSS stylesheets.
- Entry point: `assets/js/app.js`. Mounts `<App>` on `<div id="app">`.
- Components: `ChatContainer`, `MenuContainer`, `ChatMessage`, `MenuMessage`, `Hello`.
- Sockets connect from `assets/js/socket.js`.
- Dependencies: `phoenix` and `phoenix_html` pulled from `../deps/` (symlinked by mix).

## Contexts & Schemas

| Context | Module | Schemas |
|---------|--------|---------|
| Accounts | `Messengyr.Accounts` | `User` (username, email, encrypted_password + virtual password) |
| Accounts | `Messengyr.Accounts.Session` | — (auth helper, no schema) |
| Chat | `Messengyr.Chat` | `Room`, `Message`, `RoomUser` |

`Room` ↔ `User` is many_to_many via `"room_users"` join table. `Message` belongs_to both `Room` and `User`.

## Routes

### Browser
- Public: `GET /` (landing), `GET /signup`, `GET /login`, `POST /signup`, `POST /login`
- Auth-required: `GET /messages` (chat SPA — `ChatController` plugs `EnsureAuthenticated` with redirect to `/`)
- `GET /logout`

### JSON API (Bearer token required)
- `GET /api/rooms` — user's rooms with messages + counterpart
- `POST /api/rooms` — create room with `counterpartUsername`
- `GET /api/messages/:id` — single message
- `GET /api/user/:id` — user profile

All API controllers use `action_fallback MessengyrWeb.FallbackController` (returns 404 for `nil`, 403 for `:not_allowed`).

## Testing

| Test type | Use |
|-----------|-----|
| Controller | `use MessengyrWeb.ConnCase` |
| Context/model | `use Messengyr.DataCase` |
| Channel | `use MessengyrWeb.ChannelCase` |

- All checkout `Ecto.Adapters.SQL.Sandbox` in setup.
- Credentials: `postgres/postgres` on localhost.
- **No factory libraries** — tests insert data inline.
- CI: GitHub Actions (Elixir 1.12.1, OTP 24) with PostgreSQL service. Runs only `mix test`.

Existing test files: `test/messengyr/accounts/`, `test/messengyr_web/channels/`, `test/messengyr_web/controllers/`, `test/messengyr_web/views/`.

## Deployment (Heroku)

- `Procfile`: `web: MIX_ENV=prod mix phx.server`
- **Buildpacks**: Elixir (Erlang 24.0.1, Elixir 1.12) + Phoenix static (Node 14.17, npm 6.14)
- `compile` script: `npm run deploy --prefix ./assets` then `mix phx.digest`
- Host: `messengyr-app.herokuapp.com`
- Required env vars: `SECRET_KEY_BASE`, `DATABASE_URL`, `GUARDIAN_SECRET_KEY`
- `config/prod.secret.exs` is commented out — all config from env vars.

## Repo conventions

- Schema ordering: `field` → `belongs_to` → `timestamps`.
- Context modules: `alias` at module top, not inside functions.
- Changesets: `cast` → `validate_required` → constraints/format validators.
- All templates use `.eex` (no HEEx).
- No Tailwind, no daisyUI — SCSS via `node-sass` + webpack.
- LiveDashboard enabled in dev/test only (not production).
