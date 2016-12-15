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

User.changeset(%User{}, %{name: "Test Admin", email: "admin@example.com", password: "password", password_confirmation: "password"})
|> Repo.insert!
|> Coherence.ControllerHelpers.confirm!

Application.changeset(%Application{}, %{name: "Test App"})
|> Repo.insert!

Organization.changeset(%Organization{}, %{name: "Acme Inc."})
|> Repo.insert!

user = User.last
application = Application.last
organization = Organization.last

Enrollment.changeset(%Enrollment{}, %{user_id: user.id, organization_id: organization.id, is_admin: true})
|> Repo.insert!

Ownership.changeset(%Ownership{}, %{application_id: application.id, organization_id: organization.id, is_owned: true})
|> Repo.insert!
