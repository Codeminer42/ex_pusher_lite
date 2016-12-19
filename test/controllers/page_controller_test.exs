defmodule ExPusherLite.PageControllerTest do
  use ExPusherLite.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to ExPusherLite!"
  end
end
