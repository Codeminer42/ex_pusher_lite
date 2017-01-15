defmodule ExPusherLite.UserTokenControllerTest do
  use ExPusherLite.ConnCase

  setup %{conn: _conn} do
    conn = build_conn()
      |> guardian_sign_in
      |> put_req_header("accept", "application/json")

    %{assigns: %{test_user:  test_user}} = conn

    {:ok , conn: conn, user: test_user}
  end

  test "creates and returns a new user token", %{conn: conn, user: user} do
    conn = post conn, user_token_path(conn, :create, user.id)
    assert %{"id" => _id, "invalidated_at" => _invalidated, "token" => _token} = json_response(conn, 200)["data"]
  end

  test "deletes a user token", %{conn: conn, user: user} do
    conn = post conn, user_token_path(conn, :create, user.id)
    token = json_response(conn, 200)["data"]

    conn = delete conn, delete_token_path(conn, :delete, user.id, token["token"])
    updated_token = json_response(conn, 200)["data"]

    assert updated_token["id"] == token["id"]
    assert updated_token["invalidated_at"] != token["invalidated_at"]
  end
end

