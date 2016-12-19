defmodule ExPusherLite.LobbyChannel do
  use ExPusherLite.Web, :channel

  def join("lobby:" <> token, _payload, %{assigns: %{app_token: app_token}} = socket) do
    if token == app_token do
      {:ok, socket}
    else
      {:error}
    end
  end

  def handle_in(event, payload, %{assigns: %{app_token: _app_token}} = socket) do
    broadcast! socket, event, payload
    {:noreply, socket}
  end
end
