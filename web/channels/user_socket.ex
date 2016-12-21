defmodule ExPusherLite.UserSocket do
  use Phoenix.Socket
  import Guardian.Phoenix.Socket

  alias ExPusherLite.{Application, Repo}

  ## Channels
  channel "lobby:*", ExPusherLite.LobbyChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # The client-side Socket must set the token parameter
  # to be a valid ApplicationToken associated with the desired Application
  # and send a valid JWT generated through the /api/sessions?channel=true API endpoint using a valid UserToken
  def connect(%{"app_key" => app_key, "guardian_token" => jwt, "unique_identifier" => uid}, socket) do
    with {:ok, authed_socket, _} <- sign_in(socket, jwt),
         _application            <- Repo.get_by!(Application, app_key: app_key),
         user                    <- Guardian.Phoenix.Socket.current_resource(authed_socket)
      do
        authed_socket = authed_socket
          |> assign(:app_key, app_key)
          |> assign(:user_id, user.id)
          |> assign(:uid, uid)
        {:ok, authed_socket}
      else
        _err -> :error
      end
  end

  def connect(_params, _socket) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ExPusherLite.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: generate_id(socket.assigns.app_key, socket.assigns.uid)

  def generate_id(app_key, uid), do: "lobby:#{app_key}/uid:#{uid}"
end
