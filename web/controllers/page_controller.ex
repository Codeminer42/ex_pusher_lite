defmodule ExPusherLite.PageController do
  use ExPusherLite.Web, :controller

  def index(conn, _params, _current_user, _claims) do
    conn
      |> render("index.html")
  end
end
