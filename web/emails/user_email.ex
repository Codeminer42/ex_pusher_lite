Code.ensure_loaded Phoenix.Swoosh

defmodule ExPusherLite.UserEmail do
  use Phoenix.Swoosh,
    view: ExPusherLite.UserEmailView,
    layout: {ExPusherLite.LayoutView, :email}

  import ExPusherLite.EmailHelpers

  def welcome(user, token) do
    new
    |> from(from_email)
    |> to(user_email(user))
    |> subject("#{site_name} - Welcome")
    |> render_body("welcome.html", %{name: first_name(user.name), token: token})
  end
end
