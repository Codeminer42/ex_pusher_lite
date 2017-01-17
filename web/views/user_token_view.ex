defmodule ExPusherLite.UserTokenView do
  use ExPusherLite.Web, :view

  def render("show.json", %{token: token}) do
    %{data: render_one(token, ExPusherLite.UserTokenView, "token.json", as: :token)}
  end

  def render("token.json", %{token: token}) do
    %{
      id: token.id,
      token: token.token,
      invalidated_at: token.invalidated_at
     }
  end
end
