defmodule ExPusherLite.ApplicationView do
  use ExPusherLite.Web, :view

  def render("index.json", %{applications: applications}) do
    %{data: render_many(applications, ExPusherLite.ApplicationView, "application.json")}
  end

  def render("show.json", %{application: application}) do
    %{data: render_one(application, ExPusherLite.ApplicationView, "application.json")}
  end

  def render("application.json", %{application: application}) do
    %{id: application.id,
      name: application.name,
      app_key: application.app_key,
      app_secret: application.app_secret,
      archived_at: application.archived_at}
  end
end
