defmodule ExPusherLite.ApplicationTokenTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.{Application, ApplicationToken, Repo}

  @invalid_attrs %{application_id: 666}

  setup do
    {:ok, application} = Application.changeset(%Application{}, %{name: "Test App"}) |> Repo.insert

    [application: application]
  end

  test "changeset with valid attributes", context do
    assert = ApplicationToken.create_to(context[:application])
  end

  test "changeset with invalid attributes" do
    assert_raise Ecto.ConstraintError, fn ->
      ApplicationToken.create_to(@invalid_attrs)
    end
  end

  test "find application by token", context do
    {:ok, token} = ApplicationToken.create_to(context[:application])
    application = ApplicationToken.get_by(token.token)
    assert application.id == context[:application].id
  end
end
