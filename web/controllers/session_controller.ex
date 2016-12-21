defmodule ExPusherLite.SessionController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.UserToken

  def create(conn, %{"token" => token} = params, _, _) do
    if user = UserToken.get_by(token) do
      conn
        |> put_status(:created)
        |> render("show.json", jwt: UserToken.jwt(user, params))
    else
      changeset = Ecto.Changeset.change(%UserToken{})
        |> Ecto.Changeset.add_error(:token, "invalid")
      conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
