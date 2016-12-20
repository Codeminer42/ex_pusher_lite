defmodule ExPusherLite.SessionController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.UserToken

  def create(conn, %{"token" => token}, _, _) do
    user_token = from(t in UserToken,
      where: t.token == ^token and is_nil(t.invalidated_at))
      |> Repo.one

    if user_token do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user_token)
      conn
        |> put_status(:created)
        |> render("show.json", jwt: jwt)
    else
      changeset = Ecto.Changeset.change(%UserToken{})
        |> Ecto.Changeset.add_error(:token, "invalid")
      conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
