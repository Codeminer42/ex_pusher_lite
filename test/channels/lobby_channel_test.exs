defmodule ExPusherLite.LobbyChannelTest do
  use ExPusherLite.ChannelCase

  setup do
    admin_user   = create_admin_user
    application  = admin_user
      |> build_organization
      |> build_application

    socket       = connect_socket_and_join_channel(application.app_key, admin_user.id, admin_user.name)

    on_exit fn ->
      leave(socket)
    end

    {:ok, socket: socket, admin_user: admin_user, application: application}
  end

  test "socket connects through Guardian authentication", %{socket: socket, application: application, admin_user: admin_user} do
    jwt     = ExPusherLite.UserToken.jwt(admin_user, %{test: true})
    options = %{"app_key" => application.app_key, "guardian_token" => jwt, "unique_identifier" => admin_user.name}

    assert {:ok, %{assigns: %{guardian_default_jwt: ^jwt}}} = ExPusherLite.UserSocket.connect(options, socket)
  end

  test "broadcasts normal messages to general channel", %{socket: socket} do
    push socket, "new_message", %{"name" => "John Doe", "message" => "Hello World"}
    assert_broadcast "new_message", %{"name" => "John Doe", "message" => "Hello World"}
  end

  test "broadcasts direct messages, unwrapping the client side payload as a normal message", %{socket: socket, application: application, admin_user: admin_user} do
    socket2 = connect_socket_and_join_channel(application.app_key, admin_user.id, "Jane Doe")

    push socket, "direct", %{"event" => "new_message", "payload" => %{"name" => "Jane Doe", "message" => "Hello"}, "uid" => "John Wayne"}
    assert_broadcast "new_message", %{"from_uid" => "John Wayne", "name" => "Jane Doe", "message" => "Hello"}

    leave socket2
  end
end
