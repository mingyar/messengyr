# [GH#45] Message text has no length validation

**Severity:** MEDIUM
**Commit scope:** `lib/messengyr/chat/message.ex`

## Problem

`Message.changeset/2` only validates that `:text` is present — it does not
limit its length:

```elixir
def changeset(message, attrs) do
  message
  |> cast(attrs, [:text])
  |> validate_required([:text])
end
```

An attacker can send arbitrarily long messages via the channel's
`"message:new"` event, causing:
- Database storage bloat
- Slow queries when loading rooms with many oversized messages
- Potential denial of service on the frontend rendering large strings

## Fix Plan

### Step 1: Add `validate_length` to `Message.changeset`

```elixir
def changeset(message, attrs) do
  message
  |> cast(attrs, [:text])
  |> validate_required([:text])
  |> validate_length(:text, max: 5000)
end
```

5000 characters is generous for a chat message (~1000 words) while
preventing abuse.

## Verification

1. `mix test` — all tests pass
2. In `iex -S mix`:
   ```elixir
   # Normal message
   cs = Messengyr.Chat.Message.changeset(%Messengyr.Chat.Message{}, %{text: "Hello"})
   cs.valid?  # => true

   # Overly long message
   long = String.duplicate("a", 5001)
   cs = Messengyr.Chat.Message.changeset(%Messengyr.Chat.Message{}, %{text: long})
   cs.valid?  # => false
   ```
