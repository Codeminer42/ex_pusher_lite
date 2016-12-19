defmodule ExPusherLite.LobbyChannel do
  use ExPusherLite.Web, :channel

  def join("lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_message", payload, socket) do
    broadcast! socket, "new_message", payload
    {:noreply, socket}
  end

end
