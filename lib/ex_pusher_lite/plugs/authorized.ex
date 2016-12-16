defmodule ExPusherLite.Plugs.Authorized do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(default), do: default

  def call(%{assigns: %{current_user: current_user}} = conn, _) do
    if current_user.is_root do
      conn
    else
      conn
        |> flash_and_redirect
    end
  end

  def call(conn, _) do
    conn
      |> flash_and_redirect
  end

  defp flash_and_redirect(conn) do
    conn
      |> put_flash(:error, "You do not have the proper authorization to do that")
      |> redirect(to: "/")
      |> halt
  end
end
