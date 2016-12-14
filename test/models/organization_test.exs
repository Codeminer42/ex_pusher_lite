defmodule ExPusherLite.OrganizationTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.Organization

  @valid_attrs %{name: "Acme Inc."}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :slug) == "acme-inc"
  end

  test "changeset with invalid attributes" do
    changeset = Organization.changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end
end
