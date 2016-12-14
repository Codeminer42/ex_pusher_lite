defmodule ExPusherLite.ApplicationTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.Application

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Application.changeset(%Application{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Application.changeset(%Application{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "make sure app_key and app_secret are not overwritten" do
    assert {:ok, changeset } = Application.changeset(%Application{}, @valid_attrs)
      |> Repo.insert
    assert {:ok, changeset2 } = Application.changeset(changeset, %{name: "hello world"})
      |> Repo.update

    assert changeset2.name == "hello world"
    assert changeset.app_key == changeset2.app_key
    assert changeset.app_secret == changeset2.app_secret
  end
end
