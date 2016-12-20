defmodule ExPusherLite.Factory do
  alias ExPusherLite.{Repo, User, Enrollment, Ownership}

  @valid_admin_user_attrs %{name: "John Wayne", email: "john@wayne.org", password: "secret", password_confirmation: "secret", is_root: false}

  def create_admin_user(params \\ @valid_admin_user_attrs) do
    %User{}
      |> User.changeset(params)
      |> Repo.insert!
  end

  def create_admin_token(admin_user) do
    admin_user
      |> User.token_changeset
      |> Repo.insert!
  end

  def build_organization(test_user) do
    enrollment = Enrollment.changeset(%Enrollment{},
      %{user_id: test_user.id, organization: %{name: "Acme Inc."}, is_admin: true})
        |> Repo.insert!
    enrollment.organization
  end

  def build_application(organization) do
    ownership = Ownership.changeset(%Ownership{},\
      %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true})
        |> Repo.insert!
    ownership.application
  end
end
