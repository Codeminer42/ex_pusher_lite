defmodule ExPusherLite.UserToken.QueriesTest do
  use ExPusherLite.QueryCase

  alias ExPusherLite.UserToken.Queries

  test "get_first_token_by_user/1 returns a token" do
    user = create_admin_user
    token = create_admin_token(user).token

    assert token == Queries.get_first_token_by_user(user)
  end
end
