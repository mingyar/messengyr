# [GH#48] Missing `config/runtime.exs`

**Severity:** LOW
**Commit scope:** `config/runtime.exs` (new file)

## Problem

The app uses the older `import_config "#{Mix.env()}.exs"` pattern where all
config is resolved at compile time. Production secrets (`SECRET_KEY_BASE`,
`GUARDIAN_SECRET_KEY`) are read from env vars in `prod.exs`, but this means:

1. To rotate a secret, you must recompile and redeploy
2. There is no single file that documents all required runtime env vars
3. The compiled BEAM files contain the resolved values in memory

The modern Phoenix pattern is `config/runtime.exs` — loaded at application
start (not compile time), so secrets can be changed without recompiling.

## Fix Plan

### Step 1: Create `config/runtime.exs`

```elixir
import Config

# Runtime configuration — loaded at application start, not compile time.
# Use this for secrets that may change between deployments without recompiling.

if config_env() == :prod do
  config :messengyr, Messengyr.Auth.Guardian,
    secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY")

  config :messengyr, MessengyrWeb.Endpoint,
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end
```

`System.fetch_env!/1` crashes at startup with a clear error message if the
variable is missing — better than silently falling back.

### Note

No `mix.exs` change is needed — `mix release` automatically picks up
`config/runtime.exs` if it exists.

The configs in `prod.exs` can remain as-is; `runtime.exs` overrides them
at runtime. They serve as documentation of the default/expected values.

## Verification

1. `mix test` — all tests pass
2. `MIX_ENV=prod mix release` — release builds successfully
3. Run release with env vars set — app starts normally
4. Run release without `GUARDIAN_SECRET_KEY` — app fails at startup with
   `"missing environment variable GUARDIAN_SECRET_KEY"` (clear error)
