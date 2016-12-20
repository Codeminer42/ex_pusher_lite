defmodule ExPusherLite.UserTokenTest do
  use ExPusherLite.ModelCase

  alias ExPusherLite.{User, UserToken, Repo}

  @valid_user_attrs %{name: "John Wayne", email: "john@wayne.org", password: "secret", password_confirmation: "secret"}
  @invalid_attrs %{user_id: 666}

  setup do
    {:ok, user} = User.changeset(%User{}, @valid_user_attrs) |> Repo.insert

    [user: user]
  end

  test "changeset with valid attributes", context do
    assert User.token_changeset(context[:user]) |> Repo.insert!
  end

  test "changeset with invalid attributes" do
    assert_raise Ecto.ConstraintError, fn ->
      User.token_changeset(@invalid_attrs) |> Repo.insert!
    end
  end

  test "find user by token", context do
    token = User.token_changeset(context[:user]) |> Repo.insert!
    user = UserToken.get_by(token.token)
    assert user.id == context[:user].id
  end
end
