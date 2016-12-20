defmodule ExPusherLite.PageController do
  use ExPusherLite.Web, :controller

  def index(conn, _params, _current_token, _claims) do
    app_key = case ExPusherLite.Application.last do
      nil -> nil
      application -> application.app_key
    end

    conn
    |> assign(:application_token, app_key)
    |> render("index.html")
  end
end
