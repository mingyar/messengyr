# Messengyr — Phoenix 1.5 & React 16 → Latest Versions Upgrade Plan

**Date**: 2026-06-24
**Original**: Phoenix 1.5.7 / Elixir 1.9–1.12 / React 16.14 / Webpack 4
**Current**: Phoenix 1.7.23 / Elixir 1.18.2 / React 16.14 / Webpack 4
**Target**: Phoenix 1.8.8 / Elixir 1.20 / React 19.2.7 / Webpack 5

---

## Upgrade Strategy: Phased Phased Approach

This is a large jump (5+ years of releases). **Do NOT attempt all at once.** The recommended order:

| Phase | Scope | Risk |
|-------|-------|------|
| **1** | Elixir/OTP + Config + Minor deps | ✅ Done |
| **2** | Phoenix core (1.5 → 1.7) | ✅ Done |
| **3** | Phoenix 1.7 → 1.8 | Pending |
| **4** | React + Webpack (frontend overhaul) | Pending |
| **5** | Verification & cleanup | Pending |

---

## ✅ Phase 1: Foundation — Elixir/OTP & Config (Complete)

### 1.1 Upgrade Elixir requirement
```diff
- elixir: "~> 1.9",
+ elixir: "~> 1.17",
```
(Then after config migration, bump to `~> 1.20`.)

### 1.2 Replace `use Mix.Config` with `import Config` (Elixir 1.14+)
**Every config file** (`config.exs`, `dev.exs`, `prod.exs`, `test.exs`):
```diff
- use Mix.Config
+ import Config
```
This is required because `Mix.Config` was removed in Elixir 1.15+.

### 1.3 Update mix aliases
```diff
- test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
+ test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
```
(These still work, but consider `ecto.setup` pattern.)

### 1.4 Bump Elixir/OTP in CI and buildpacks
**.github/workflows/elixir.yml**:
```diff
- elixir-version: '1.12.1'
- otp-version: '24'
+ elixir-version: '1.20.1'
+ otp-version: '27'
```

**elixir_buildpack.config**:
```diff
- erlang_version=24.0.1
- elixir_version=1.12
+ erlang_version=27.3
+ elixir_version=1.20
```

**phoenix_static_buildpack.config**:
```diff
- node_version=14.17.0
+ node_version=22.x
```

### 1.5 Update mix.exs deps — Phase 1 (safe minor bumps)

```diff
- {:phoenix_ecto, "~> 4.1"},
- {:ecto_sql, "~> 3.4"},
- {:postgrex, ">= 0.0.0"},
- {:phoenix_live_reload, "~> 1.2", only: :dev},
- {:phoenix_live_dashboard, "~> 0.4"},
- {:telemetry_metrics, "~> 0.4"},
- {:telemetry_poller, "~> 0.4"},
- {:gettext, "~> 0.11"},
- {:jason, "~> 1.0"},
- {:plug_cowboy, "~> 2.0"},
- {:bcrypt_elixir, "~> 2.0"},
- {:guardian, "~> 2.1"},
- {:ex_doc, "~> 0.24", only: :dev, runtime: false},

+ {:phoenix_ecto, "~> 4.7"},
+ {:ecto_sql, "~> 3.14"},
+ {:postgrex, ">= 0.22.0"},
+ {:phoenix_live_reload, "~> 1.6", only: :dev},
+ {:phoenix_live_dashboard, "~> 0.8"},
+ {:telemetry_metrics, "~> 1.0"},
+ {:telemetry_poller, "~> 1.1"},
+ {:gettext, "~> 0.26"},
+ {:jason, "~> 1.4"},
+ {:plug_cowboy, "~> 2.8"},
+ {:bcrypt_elixir, "~> 3.3"},
+ {:guardian, "~> 2.4"},
+ {:ex_doc, "~> 0.37", only: :dev, runtime: false},
```

✅ After this phase: `mix deps.get && mix test` should pass.

---

## ✅ Phase 2: Phoenix 1.5 → 1.7 Migration (Complete)

### 2.1 Update Phoenix version
```diff
- {:phoenix, "~> 1.5.7"},
+ {:phoenix, "~> 1.7.23"},
```

### 2.2 Key Phoenix 1.6→1.7 changes that affect this codebase

#### 2.2.1 `MessengyrWeb` module — Add `static_paths` and `verified_routes`
```elixir
# lib/messengyr_web.ex
def controller do
  quote do
    use Phoenix.Controller, namespace: MessengyrWeb
    import Plug.Conn
    import MessengyrWeb.Gettext
    # Phoenix 1.7: replace Router.Helpers with verified routes
    # alias MessengyrWeb.Router.Helpers, as: Routes  ← REMOVE
    unquote(verified_routes())
  end
end

def view do
  quote do
    use Phoenix.View, root: "lib/messengyr_web/templates", namespace: MessengyrWeb
    import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]
    unquote(view_helpers())
  end
end

defp view_helpers do
  quote do
    use Phoenix.HTML
    import Phoenix.View
    import MessengyrWeb.ErrorHelpers
    import MessengyrWeb.Gettext
    unquote(verified_routes())
  end
end

defp verified_routes do
  quote do
    import MessengyrWeb.Router.Helpers, only: []
    # Phoenix 1.7+ uses ~p sigil
    import Phoenix.VerifiedRoutes
  end
end
```

Alternative: Keep `Router.Helpers` for now and add `Phoenix.VerifiedRoutes` alongside. The `~p` sigil is opt-in until Phoenix 1.8 makes it the default.

#### 2.2.2 Endpoint: Remove LiveView socket (bundled with Phoenix in 1.7)
```diff
- socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
```
(Phoenix 1.7+ handles this internally.)

#### 2.2.3 Router: LiveDashboard import changes
In Phoenix 1.7+, `live_dashboard` lives under `Phoenix.LiveDashboard.Router`:
```diff
- import Phoenix.LiveDashboard.Router
+ import Phoenix.LiveDashboard.Router, warn_on_dashboard_routes_not_prefixed: false
```

#### 2.2.4 Router: Scope syntax stays the same for now (1.8 adds scope as first param)

#### 2.2.5 Config: Add `phoenix_live_view` config for LiveView signing salt
```diff
- live_view: [signing_salt: "hIKyiFxV"]
```
Move to:
```elixir
config :phoenix_live_view,
  signing_salt: "hIKyiFxV"
```

#### 2.2.6 Replace `@inner_content` with `@inner_content` (unchanged)
Actually `@inner_content` still works, but in newer templates you can use `<.inner_layout>` blocks. Not required for EEx templates.

### 2.3 `phoenix_html` 2.x → 4.x

This is the riskiest part of Phase 2.

**Changes in phoenix_html 3.x / 4.x:**
- `Phoenix.HTML.Tag.content_tag/3` is deprecated → use `Phoenix.HTML.Tag.content_tag/2` or HEEx syntax
- `form_for` still works but is deprecated in 4.x in favor of `<.form>` (HEEx only)
- The `error_tag` helper in `error_helpers.ex` uses `input_id/2` and `phx_feedback_for` which still work

Since you use EEx templates (not HEEx), the old API will still work but will emit deprecation warnings. Plan to:
1. **Keep EEx for now** — suppress warnings by pinning `phoenix_html` to `~> 3.3` instead of `~> 4.3` as a middle ground
2. Or jump to 4.3 and accept the deprecation warnings

**Recommendation**: Pin `phoenix_html` to `~> 3.3` first, upgrade everything else, then tackle the EEx→HEEx migration in a later phase.

```diff
- {:phoenix_html, "~> 2.11"},
+ {:phoenix_html, "~> 3.3"},
```

### 2.4 Verify Bcrypt API still matches
Current code uses `Bcrypt.hash_pwd_salt/1`. In bcrypt_elixir 3.x, this is still supported via the `Comeonin` compatibility layer. Verify:
```elixir
# lib/messengyr/accounts/accounts.ex
encrypted_password = password |> Bcrypt.hash_pwd_salt  # Still works in 3.x
```

### 2.5 Guardian — no breaking changes from 2.1 to 2.4

✅ After this phase: `mix deps.get && mix test` should pass.

---

## Phase 3: Phoenix 1.7 → 1.8 Migration

### 3.1 Update Phoenix
```diff
- {:phoenix, "~> 1.7.23"},
+ {:phoenix, "~> 1.8.8"},
```

### 3.2 Scopes as first parameter (Phoenix 1.8)

**Current router**:
```elixir
scope "/", MessengyrWeb do
  pipe_through [:browser, :browser_session]
  get "/", PageController, :index
  ...
end
```

**New in 1.8**: Scope as first parameter:
```elixir
scope "/", MessengyrWeb, [:browser, :browser_session] do
  get "/", PageController, :index
  ...
end
```

This is backward-compatible for now. The old style will produce deprecation warnings eventually. You can migrate gradually.

### 3.3 Verified routes (~p sigil migration)

Replace path helpers (`Routes.page_path(@conn, :index)`) with `~p"/"` throughout:

**In templates (app.html.eex):**
```diff
- <link rel="stylesheet" href="<%= Routes.static_path(@conn, "/css/app.css") %>"/>
+ <link rel="stylesheet" href={~p"/css/app.css"}/>
- <script defer type="text/javascript" src="<%= Routes.static_path(@conn, "/js/app.js") %>"></script>
+ <script defer type="text/javascript" src={~p"/js/app.js"}></script>
```

**In header.html.eex:**
```diff
- <%= link " ", class: "logo", to: Routes.page_path(@conn, :index) %>
+ <%= link " ", class: "logo", to: ~p"/" %>
- <%= link "Log out", to: Routes.page_path(@conn, :logout) %>
+ <%= link "Log out", to: ~p"/logout" %>
```

**In page templates:**
```diff
- <%= form_for @conn, Routes.page_path(@conn, :login_user), [as: :credentials], fn f -> %>
+ <%= form_for @conn, ~p"/login", [as: :credentials], fn f -> %>
```

**In controllers:**
```diff
- redirect(to: "/login")
+ redirect(to: ~p"/login")
- redirect(to: "/messages")
+ redirect(to: ~p"/messages")
```

### 3.4 Router: Remove `Router.Helpers` alias

```diff
- alias MessengyrWeb.Router.Helpers, as: Routes
```
Once all path references use `~p`, this alias is no longer needed in `MessengyrWeb`.

### 3.5 LiveDashboard: Update router configuration

In Phoenix 1.8, the `live_dashboard` macro path changes slightly:
```elixir
scope "/" do
  pipe_through :browser
  live_dashboard "/dashboard", metrics: MessengyrWeb.Telemetry
end
```
This should still work, but you may want to add `warn_on_dashboard_routes_not_prefixed: false`.

✅ After this phase: `mix test` with verified routes should pass.

---

## Phase 4: Frontend — React 16 → 19 & Webpack 4 → 5

### 4.1 Webpack 4 → 5 & ESBuild consideration

**Option A: Keep Webpack (more work but less disruption)**
Upgrade webpack 4 → 5, replace deprecated loaders.

**Option B: Switch to esbuild (Phoenix convention)**
New Phoenix generators use esbuild for JS and tailwind/dart-sass for CSS.
This would mean rewriting `webpack.config.js` into `config.exs` esbuild config.

**Recommendation: Option A — Keep Webpack 5** for minimal frontend disruption.

### 4.2 Webpack config changes (4→5)

```javascript
// webpack.config.js — key changes:
- const HardSourceWebpackPlugin = require('hard-source-webpack-plugin');  // REMOVE
- const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin'); // REMOVE
+ const CssMinimizerPlugin = require('css-minimizer-webpack-plugin'); // REPLACE

// Webpack 5 has built-in caching — no HardSource needed
// Webpack 5 has asset modules — replace url-loader:
- {
-   test: /\.(png|jpg|gif|svg)$/i,
-   use: [{ loader: 'url-loader', options: { limit: 8192 } }],
- }
+ {
+   test: /\.(png|jpg|gif|svg)$/i,
+   type: 'asset',
+   parser: { dataUrlCondition: { maxSize: 8192 } },
+ }

// Update minimizer for CSS:
- new OptimizeCSSAssetsPlugin({})
+ new CssMinimizerPlugin()

// Webpack 5 resolve config:
optimization: {
  minimizer: [
    new TerserPlugin({ parallel: true }),
    new CssMinimizerPlugin(),
  ],
  // Webpack 5 no longer needs these in minimizer config
},

// CopyWebpackPlugin syntax changed in v6+:
- new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
+ new CopyWebpackPlugin({ patterns: [{ from: 'static/', to: '../' }] })

// MiniCssExtractPlugin — check version compatibility
// Remove duplicate `resolve` key in config (webpack.config.js has two resolve blocks!)
```

### 4.3 Package.json dependency updates

```diff
- "webpack": "^4.46.0",
- "webpack-cli": "^3.3.2",
+ "webpack": "^5.107.2",
+ "webpack-cli": "^5.1.4",

- "hard-source-webpack-plugin": "^0.13.1",  // REMOVE (not compatible with WP5)
- "node-sass": "^4.0.0",  // REMOVE (deprecated)
+ "sass": "^1.77.0",  // dart sass
+ "sass-loader": "^14.0.0",  // for WP5 compatibility

- "optimize-css-assets-webpack-plugin": "^5.0.6",  // REMOVE
+ "css-minimizer-webpack-plugin": "^6.0.0",

- "url-loader": "^4.1.1",  // REMOVE (WP5 has asset modules built-in)

- "copy-webpack-plugin": "^5.1.1",
+ "copy-webpack-plugin": "^12.0.0",

- "terser-webpack-plugin": "^4.2.3",
+ "terser-webpack-plugin": "^5.3.0",

- "css-loader": "^5.2.4",
+ "css-loader": "^7.0.0",

- "mini-css-extract-plugin": "^1.6.0",
+ "mini-css-extract-plugin": "^2.9.0",

- "style-loader": "^2.0.0",
+ "style-loader": "^4.0.0",
```

### 4.4 Babel updates

```diff
- "@babel/core": "^7.14.3",
- "@babel/preset-env": "^7.14.4",
- "@babel/preset-react": "^7.13.13",
- "babel-loader": "^8.0.0",
+ "@babel/core": "^7.24.0",
+ "@babel/preset-env": "^7.24.0",
+ "@babel/preset-react": "^7.24.0",
+ "babel-loader": "^9.1.0",
```

Add `browserslist` to package.json:
```json
"browserslist": [
  "last 1 version",
  "> 1%",
  "not dead"
]
```

### 4.5 React 16 → 19 migration

**Step 1: Upgrade to React 18 first**
```diff
- "react": "^16.14.0",
- "react-dom": "^16.14.0",
+ "react": "^18.3.0",
+ "react-dom": "^18.3.0",
- "react-redux": "^7.2.4",
- "redux": "^4.1.0",
+ "react-redux": "^8.1.0",
+ "redux": "^4.2.1",  // Redux 5 can come later
```

**Changes needed for React 18:**
```diff
- ReactDOM.render(
-   <Provider store={store}>
-     <App />
-   </Provider>,
-   document.getElementById('app'),
- );
+ import { createRoot } from 'react-dom/client';
+ const root = createRoot(document.getElementById('app'));
+ root.render(
+   <Provider store={store}>
+     <App />
+   </Provider>
+ );
```

**Step 2: Upgrade to React 19**
```diff
- "react": "^18.3.0",
- "react-dom": "^18.3.0",
+ "react": "^19.2.7",
+ "react-dom": "^19.2.7",
- "react-redux": "^8.1.0",
+ "react-redux": "^9.1.0",
```

React 19 changes to be aware of:
- `ref` can be passed as a prop (no more `forwardRef`)
- `use()` API available
- New hooks: `useActionState`, `useFormStatus`, `useOptimistic`
- String refs removed
- Legacy context removed
- Class component `defaultProps` for function components will warn
- The `App` component is a class component — it still works in React 19

**Add babel config for new JSX transform** (no need to `import React`):
Update babel config in webpack:
```diff
- presets: ['@babel/preset-env', '@babel/react']
+ presets: [
+   ['@babel/preset-env', { targets: { browsers: ['last 1 version'] } }],
+   ['@babel/preset-react', { runtime: 'automatic' }]
+ ]
```
With `runtime: 'automatic'`, you no longer need `import React from 'react'` in every component. However, since you use class components, you still need `import React from 'react'` for `React.Component`.

### 4.6 SCSS: node-sass → dart sass

`node-sass` is deprecated. Replace with `sass` (dart sass).

```diff
- "node-sass": "^4.0.0",
- "sass-loader": "^5.0.0",
+ "sass": "^1.77.0",
+ "sass-loader": "^14.0.0",
```

The sass-loader API changed. In webpack 5 with sass-loader v14:
```javascript
{
  test: /\.[s]?css$/,
  use: [
    MiniCssExtractPlugin.loader,  // use MiniCssExtractPlugin.loader in prod
    'css-loader?url=false',
    'sass-loader',
  ]
}
```

### 4.7 Webpack dev watcher config in dev.exs

In Phoenix 1.7+, the dev watcher config format changed:
```diff
config :messengyr, MessengyrWeb.Endpoint,
  watchers: [
-   node: [
-     "node_modules/webpack/bin/webpack.js",
-     "--mode",
-     "development",
-     "--watch-stdin",
-     cd: Path.expand("../assets", __DIR__)
-   ]
+   npx: [
+     "webpack",
+     "--mode",
+     "development",
+     "--watch-stdin",
+     cd: Path.expand("../assets", __DIR__)
+   ]
  ]
```
(Also verify `node_modules/webpack/bin/webpack.js` path exists in WP5.)

### 4.8 Remove unused dependencies

- `hard-source-webpack-plugin` (not WP5 compatible)
- `node-sass` (deprecated)
- `url-loader` (replaced by WP5 asset modules)
- Possibly `whatwg-fetch` (fetch is well-supported now)
- `moment` (consider replacing with native Date/Intl or `date-fns`)

### 4.9 Live reload patterns update

Phoenix 1.7+ changed `live_reload` patterns slightly:
```diff
- ~r"lib/messengyr_web/templates/.*(eex)$"
+ ~r"lib/messengyr_web/templates/.*(eex|heex)$"
```

---

## Phase 5: Cleanup & Verification

### 5.1 Verify `config/prod.secret.exs`
Currently commented out. You may want to remove it entirely since env vars are used.

### 5.2 Phoenix.Template → Phoenix.Template.Live
Not applicable (no LiveView), but verify any template-related functions.

### 5.3 Test support files
Update `test/support/*` to match new Phoenix versions:

**conn_case.ex**: The `@endpoint` module attribute and `Phoenix.ConnTest.build_conn()` still work. No changes needed.

**channel_case.ex**: Same — stable API.

**data_case.ex**: Same — stable API.

### 5.4 Remove `config :phoenix, :plug_init_mode, :runtime` if no longer needed
This was helpful in Phoenix 1.5 for dev speed. May not be needed or may be default now.

### 5.5 Verify Guardian pipeline references

In `router.ex`, Guardian pipeline references `Messengyr.Guardian` but the actual module is `Messengyr.Auth.Guardian`:
```diff
- plug Guardian.Plug.Pipeline, module: Messengyr.Guardian, ...
+ plug Guardian.Plug.Pipeline, module: Messengyr.Auth.Guardian, ...
```
This compiles due to Guardian's internal alias resolution, but should be fixed for clarity.

### 5.6 Add Elixir 1.19+ type hints (optional)
Since Elixir 1.20 now has gradual typing, consider adding specs to public functions:
```elixir
@spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
def create_user(%{"password" => password} = params) do
```

---

## Key Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `phoenix_html` 2→4 breaks `form_for` | High | Pin to 3.3 initially, migrate forms later |
| `node-sass`→`dart-sass` CSS differences | Medium | Run visual diff after upgrade |
| React 16→19 class component changes | Low | Class components still work in React 19 |
| Webpack 4→5 plugin incompatibility | High | Replace HardSourcePlugin, url-loader, optimize-css-assets |
| `use Mix.Config` removal | Low | Straightforward search/replace |
| Elixir 1.20 type system warnings | Low | Fix warnings as they appear |

---

## Rollback Strategy

After each phase:
1. `mix test` must pass
2. `mix phx.server` must start without warnings
3. Git commit with tag per phase (e.g., `phase-1-config-upgrade`)

If any phase fails, roll back with `git reset --hard` before the phase commit.

---

## Target Deps Summary

| Package | Current | Target |
|---------|---------|--------|
| Elixir | ~> 1.9 | ~> 1.20 |
| Erlang/OTP | 24 | 27+ |
| Phoenix | 1.5.7 | 1.8.8 |
| phoenix_ecto | 4.1 | 4.7 |
| ecto_sql | 3.4 | 3.14 |
| postgrex | >= 0.0.0 | >= 0.22 |
| phoenix_html | 2.11 | 3.3→4.3 |
| phoenix_live_dashboard | 0.4 | 0.8 |
| plug_cowboy | 2.0 | 2.8 |
| bcrypt_elixir | 2.0 | 3.3 |
| guardian | 2.1 | 2.4 |
| telemetry_metrics | 0.4 | 1.0 |
| telemetry_poller | 0.4 | 1.1 |
| **React** | **16.14** | **19.2.7** |
| **React-DOM** | **16.14** | **19.2.7** |
| Redux | 4.1 | 4.2 (→5.0) |
| React-Redux | 7.2 | 9.1 |
| **Webpack** | **4.46** | **5.107** |
| Babel | 7.14 | 7.24+ |
| Sass | node-sass 4 | dart-sass 1.77 |
