defmodule ExPusherLite.LobbyChannel do
  use ExPusherLite.Web, :channel
  require Logger

  alias ExPusherLite.Presence

  def join("lobby:" <> topic_identifier, _payload, socket) do
    case parse_identifier(topic_identifier) do
    {:ok, %{app_key: _app_key, topic: _topic}} ->
      send(self(), :after_join)
      {:ok, socket}
    {:error, _} ->
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

  def handle_in(event, payload, %{assigns: %{app_key: _app_key, uid: _from_uid}} = socket) do
    broadcast! socket, event, payload
    {:noreply, socket}
  end

  # the pattern match on the socket's assigns ensures the socket is authenticated, otherwise falls back here
  def handle_in(event, _payload, socket) do
    Logger.info "invalid event #{event} to unauthenticated socket"
    {:noreply, socket}
  end

  defp parse_identifier(identifier) do
    tokens = String.split(identifier, ":", parts: 2, trim: true)
    if tokens |> Enum.count() == 2 do
      {:ok, %{app_key: Enum.at(tokens, 0), topic: Enum.at(tokens, 1)}}
    else
      {:error, "invalid topic identifier"}
    end
  end
end
