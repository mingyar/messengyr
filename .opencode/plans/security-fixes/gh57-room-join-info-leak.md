# [GH#57] Room channel join errors leak room existence

**Severity:** MEDIUM
**Commit scope:** `lib/messengyr_web/channels/room_channel.ex`

## Problem

`RoomChannel.join/3` returns different error messages depending on the reason
for failure:

```elixir
# Room exists but user is not a member:
{:error, %{reason: "You're not a member of this room!"}}

# Room does not exist:
{:error, %{reason: "This room doesn't exist!"}}
```

An attacker can probe room IDs via WebSocket and distinguish between "room
exists" and "room does not exist" based on the error message. This information
disclosure helps attackers map the application's data.

## Fix Plan

### Step 1: Replace `join/3` in `room_channel.ex`

```elixir
@impl true
def join("room:" <> room_id, _payload, socket) do
  me = socket.assigns.current_user

  case Chat.get_room(room_id) do
    %Room{} = room ->
      if Chat.room_has_user?(room, me) do
        {:ok, socket}
      else
        {:error, %{reason: "Room not found"}}
      end

    _ ->
      {:error, %{reason: "Room not found"}}
  end
end
```

Both error paths now return the exact same message — `"Room not found"`.
The attacker gets zero information about whether the room exists.

## Verification

1. `mix test` — all tests pass
2. Open chat app in browser — joining owned rooms still works
3. Via WebSocket console: joining a non-existent room returns
   `{"reason": "Room not found"}`
4. Via WebSocket console: joining a room you don't belong to returns the
   same `{"reason": "Room not found"}` — indistinguishable
