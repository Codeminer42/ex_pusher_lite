defmodule ExPusherLite.GuardianSerializer do
  @behaviour Guardian.Serializer

  import Ecto.Query

  alias ExPusherLite.{User, UserToken, Repo}

  def for_token(user_token = %UserToken{}), do: { :ok, "UserToken:#{user_token.token}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("UserToken:" <> token) do
    user_token = from(t in UserToken,
      join: a in User, on: a.id == t.user_id,
      where: t.token == ^token and is_nil(t.invalidated_at),
      preload: [:user])
        |> Repo.one
    { :ok, user_token }
  end

  def from_token(_), do: { :error, "Unknown resource type" }
end
