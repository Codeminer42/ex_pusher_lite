defmodule ExPusherLite.UserSocket do
  use Phoenix.Socket

  alias ExPusherLite.{Application, Repo}

  ## Channels
  channel "lobby:*", ExPusherLite.LobbyChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # The client-side Socket must set the token parameter
  # to be a valid ApplicationToken associated with the desired Application
  def connect(%{"token" => token}, socket) do
    case Repo.get_by(Application, app_key: token) do
      nil ->
        :error
      _application ->
        {:ok, assign(socket, :app_token, token)}
    end
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
  def id(socket), do: "applications_socket:#{socket.assigns.app_token}"
end
