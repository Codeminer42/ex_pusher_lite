# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExPusherLite.Repo.insert!(%ExPusherLite.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ExPusherLite.{Repo, User}

Repo.delete_all User

User.changeset(%User{}, %{name: "Test Admin", email: "admin@example.com", password: "password", password_confirmation: "password"})
|> Repo.insert!
|> Coherence.ControllerHelpers.confirm!
