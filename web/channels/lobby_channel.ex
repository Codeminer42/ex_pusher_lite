defmodule ExPusherLite.LobbyChannel do
  use ExPusherLite.Web, :channel
  require Logger

  alias ExPusherLite.UserSocket
  alias ExPusherLite.Presence

  def join("lobby:" <> token, _payload, socket) do
    [app_key, uid] = parse_token(token)
    if socket.assigns.app_key == app_key and checks_uid(socket.assigns.uid, uid) do
      send(self, :after_join)
      {:ok, socket}
    else
      {:error, "invalid"}
    end
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.uid, %{
      online_at: System.system_time(:milliseconds)
    })
    {:noreply, socket}
  end

  def handle_in("direct", %{"event" => event, "payload" => client_payload, "uid" => to_uid}, %{assigns: %{app_key: app_key, uid: from_uid}} = socket) do
    client_payload = client_payload
      |> Map.put("from_uid", from_uid)

    app_key
      |> UserSocket.generate_id(to_uid)
      |> ExPusherLite.Endpoint.broadcast(event, client_payload)

    {:noreply, socket}
  end

  def handle_in(event, payload, %{assigns: %{app_key: _app_key, uid: _from_uid}} = socket) do
    broadcast! socket, event, payload
    {:noreply, socket}
  end

  # the pattern match on the socket's assigns ensures the socket is authenticated, otherwise falls back here
  def handle_in(event, _payload, socket) do
    Logger.info "invalid event #{event} to unauthenticated socket"
    {:noreply, socket}
  end

  defp parse_token(token) do
    if String.contains?(token, "/uid:") do
      String.split(token, "/uid:")
    else
      [token, nil]
    end
  end

  defp checks_uid(assigns_uid, uid) do
    if !is_nil(assigns_uid) do
      if !is_nil(uid) and assigns_uid == uid do
        true
      end
      true
    else
      false
    end
  end
end
