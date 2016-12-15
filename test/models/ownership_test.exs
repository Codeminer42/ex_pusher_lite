defmodule ExPusherLite.OwnershipTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.{Organization, Application, Ownership, Repo}

  @valid_attrs_application %{name: "Foo App"}
  @valid_attrs_organization %{name: "Acme Inc."}
  @invalid_attrs %{name: nil}

  setup do
    {:ok, application} = Application.changeset(%Application{}, @valid_attrs_application) |> Repo.insert
    {:ok, organization} = Organization.changeset(%Organization{}, @valid_attrs_organization) |> Repo.insert
    ownership_params = %{application_id: application.id, organization_id: organization.id}
    [application: application, organization: organization, ownership: ownership_params]
  end

  test "changeset with valid attributes", context do
    changeset = Ownership.changeset(%Ownership{}, context[:ownership])
    assert changeset.valid?
  end

  test "that can preload applications by fetching organization, going through the ownership", context do
    Ownership.changeset(%Ownership{}, context[:ownership])
      |> Repo.insert

    organization = from(o in Organization, preload: :applications)
      |> Repo.get(context[:organization].id)
    application = organization.applications
      |> Enum.at(0)
    assert application.name == context[:application].name
  end

  test "that can preload organizations by fetching application, going through the ownership", context do
    Ownership.changeset(%Ownership{}, context[:ownership])
      |> Repo.insert

    application = from(a in Application, preload: :organizations)
      |> Repo.get(context[:application].id)
    organization = application.organizations
      |> Enum.at(0)
    assert organization.name == context[:organization].name
  end
end
