defmodule ExPusherLite.UserTokenController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.UserToken

  def create(conn, %{"user_id" => user_id} = _params, _current_user, _claims) do
    {id, _} = Integer.parse(user_id)
    changeset = UserToken.changeset(%UserToken{token: UUID.uuid1(), user_id: id})

    case Repo.insert(changeset) do
      {:ok, token} ->
        render(conn, "show.json", token: token)
      {:error, changeset} ->
        render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"token" => token} = _params, _current_user, _claims) do
    token = Repo.get_by(UserToken, token: token) |> Repo.preload(:user)
    changeset = UserToken.changeset(token, %{invalidated_at: :calendar.local_time})

    case Repo.update(changeset) do
      {:ok, token} ->
        render(conn, "show.json", token: token)
      {:error, changeset} ->
        render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
