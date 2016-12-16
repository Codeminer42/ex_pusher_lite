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

alias ExPusherLite.{Repo, User, Application, Organization, Ownership, Enrollment}

Repo.delete_all User
Repo.delete_all Application
Repo.delete_all Organization

User.changeset(%User{}, %{name: "Test Admin", email: "admin@example.com", password: "password", password_confirmation: "password", is_root: true})
|> Repo.insert!
|> Coherence.ControllerHelpers.confirm!

Organization.changeset(%Organization{}, %{name: "Acme Inc."})
|> Repo.insert!

user = User.last
organization = Organization.last

Enrollment.changeset(%Enrollment{}, %{user_id: user.id, organization_id: organization.id, is_admin: true})
|> Repo.insert!

Ownership.changeset(%Ownership{}, %{organization_id: organization.id, is_owned: true, application: %{name: "Test App"}})
|> Repo.insert!
