defmodule ExPusherLite.EnrollmentTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.{Organization, User, Enrollment, Repo}

  @valid_attrs_user %{name: "John Doe", email: "john@example.org", password: "password", password_confirmation: "password"}
  @valid_attrs_organization %{name: "Acme Inc."}
  @invalid_attrs %{}

  setup do
    {:ok, user} = User.changeset(%User{}, @valid_attrs_user) |> Repo.insert
    {:ok, organization} = Organization.changeset(%Organization{}, @valid_attrs_organization) |> Repo.insert
    enrollment_params = %{user_id: user.id, organization_id: organization.id}
    [user: user, organization: organization, enrollment: enrollment_params]
  end

  test "changeset with valid attributes", context do
    changeset = Enrollment.changeset(%Enrollment{}, context[:enrollment])
    assert changeset.valid?
  end

  test "that can preload users by fetching organization, going through the enrollment", context do
    Enrollment.changeset(%Enrollment{}, context[:enrollment])
      |> Repo.insert

    organization = from(o in Organization, preload: :users)
      |> Repo.get(context[:organization].id)
    user = organization.users
      |> Enum.at(0)
    assert user.name == context[:user].name
  end

  test "that can preload organizations by fetching user, going through the enrollment", context do
    Enrollment.changeset(%Enrollment{}, context[:enrollment])
      |> Repo.insert

    user = from(o in User, preload: :organizations)
      |> Repo.get(context[:user].id)
    organization = user.organizations
      |> Enum.at(0)
    assert organization.name == context[:organization].name
  end
end
