defmodule ExPusherLite.PageController do
  use ExPusherLite.Web, :controller

  def index(conn, _params, _current_user, _claims) do
    conn
      |> render("index.html")
  end

  def create(conn, %{"name" => username}, _current_user, _claims) do
    app_key = case ExPusherLite.Application.last do
      nil -> nil
      application -> application.app_key
    end

    guardian_token = case ExPusherLite.User.last do
      nil -> nil
      user -> ExPusherLite.UserToken.jwt(user, %{"channel" => true})
    end

    conn
    |> assign(:application_token, app_key)
    |> assign(:guardian_token, guardian_token)
    |> assign(:username, username)
    |> render("show.html")
  end
end
