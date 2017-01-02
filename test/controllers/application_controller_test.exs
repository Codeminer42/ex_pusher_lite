defmodule ExPusherLite.ApplicationControllerTest do
  use ExPusherLite.ConnCase

  alias ExPusherLite.{Application, Ownership}
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{name: nil}

  # Hack module to be able to access the websocket connection
  defmodule EventChannelTest do
    use ExPusherLite.ChannelCase
  end

  setup %{conn: _conn} do
    conn = build_conn()
      |> guardian_sign_in
      |> put_req_header("accept", "application/json")

    %{assigns: %{test_user: test_user}} = conn

    {:ok, conn: conn, organization: build_organization(test_user), user: test_user}
  end

  test "lists all entries on index", %{conn: conn, organization: organization} do
    conn = get conn, organization_application_path(conn, :index, organization)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn, organization: organization} do
    application = build_application(organization)
    conn = get conn, organization_application_path(conn, :show, organization, application)
    assert json_response(conn, 200)["data"] == %{"id" => application.id,
      "name" => application.name,
      "app_key" => application.app_key,
      "app_secret" => application.app_secret,
      "archived_at" => application.archived_at}
  end

  test "renders page not found when id is nonexistent", %{conn: conn, organization: organization} do
    assert_error_sent 404, fn ->
      get conn, organization_application_path(conn, :show, organization, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, organization: organization} do
    conn = post conn, organization_application_path(conn, :create, organization), application: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Application, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    conn = post conn, organization_application_path(conn, :create, organization), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, organization: organization} do
    application = build_application(organization)
    conn = put conn, organization_application_path(conn, :update, organization, application), application: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Application, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    application = build_application(organization)
    conn = put conn, organization_application_path(conn, :update, organization, application), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, organization: organization} do
    application = build_application(organization)
    conn = delete conn, organization_application_path(conn, :delete, organization, application)
    assert response(conn, 204)
    refute Repo.get(Application, application.id)
    assert Repo.aggregate(Ownership, :count, :id) == 0
  end

  test "broadcasts events to channel", %{conn: conn, organization: organization, user: user} do
    application = build_application(organization)

    room_name = ExPusherLite.UserSocket.generate_id(application.app_key)
    params    = %{name: "John Wayne", message: "Hello World"}

    EventChannelTest.connect_socket_and_join_channel(application.app_key, user.id, user.name)

    post conn, organization_application_event_path(conn, :event, organization, application, "new_message"), params

    assert_receive %Phoenix.Socket.Message{
      event: "new_message",
      payload: %{"message" => "Hello World", "name" => "John Wayne"},
      topic: ^room_name}
  end

  test "fetches the presence tracking list", %{conn: conn, organization: organization, user: user} do
    application = build_application(organization)

    room_name = ExPusherLite.UserSocket.generate_id(application.app_key, "Jane Doe")

    EventChannelTest.connect_socket_and_join_channel(application.app_key, user.id, user.name)
    EventChannelTest.connect_socket_and_join_channel(application.app_key, user.id, "Jane Doe")

    ExPusherLite.Endpoint.subscribe(room_name)
    conn = post conn, organization_application_event_path(conn, :event, organization, application, "presence_list"), %{}
    assert json_response(conn, 200)["data"]["John Wayne"]
    assert json_response(conn, 200)["data"]["Jane Doe"]
  end
end
