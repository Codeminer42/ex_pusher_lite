defmodule ExPusherLite.SessionView do
  use ExPusherLite.Web, :view

  def render("show.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
