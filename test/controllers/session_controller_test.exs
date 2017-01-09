defmodule ExPusherLite.SessionControllerTest do
  use ExPusherLite.ConnCase

  setup %{conn: _conn} do
    token = create_admin_user()
      |> create_admin_token

    conn = build_conn()
      |> assign(:user_token, token)

    {:ok, conn: conn}
  end

  test "return a JWT authorization from a valid token", %{conn: %{assigns: %{user_token: user_token}} = conn} do
    conn = post conn, sign_in_path(conn, :create), token: user_token.token
    assert json_response(conn, 201)["jwt"]
  end
end
