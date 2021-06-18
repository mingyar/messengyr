# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Messengyr.Repo.insert!(%Messengyr.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Messengyr.{Chat, Repo, Accounts}
alias Messengyr.Accounts.User

{:ok, room} = Chat.create_room()

me = Repo.one(User)

{:ok, counterpart} = Accounts.create_user(%{
  "username" => "bob",
  "email" => "bob@example.com",
  "password" => "test"
})

Chat.add_room_user(room, me)

Chat.add_room_user(room, counterpart)

Chat.add_message(%{
  room: room,
  user: me,
  text: "Hello world"
})
