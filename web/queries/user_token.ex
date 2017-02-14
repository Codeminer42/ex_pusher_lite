defmodule ExPusherLite.UserToken.Queries do
  import Ecto.Query
  alias ExPusherLite.{Repo, User, UserToken}

  def get_first_token_by_user(%User{id: user_id}) do
    (from ut in UserToken,
    where: ut.user_id == ^user_id,
    select: ut.token)
    |> Repo.one
  end
end
