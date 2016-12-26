defmodule ExPusherLite.UserToken do
  use ExPusherLite.Web, :model

  alias ExPusherLite.User

  schema "user_tokens" do
    field :token, :string
    field :invalidated_at, Ecto.DateTime

    timestamps()

    belongs_to :user, User
  end

  @required_fields [:token]
  @optional_fields [:user_id, :invalidated_at]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> generate_uuid(:token)
    |> validate_required(@required_fields)
    |> cast_assoc(:user)
  end

  def get_by(token) do
    from(a in User,
      join: t in ExPusherLite.UserToken, on: a.id == t.user_id,
      where: t.token == ^token and is_nil(t.invalidated_at))
    |> Repo.one
  end

  def jwt(user, params) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :access, get_perms(user, params))
    jwt
  end

  defp get_perms(%User{} = user, _params) do
    perms = %{ default: Guardian.Permissions.max }
    query = from e in ExPusherLite.Enrollment,
      where: e.user_id == ^user.id and e.is_admin == true
    if Repo.one(query) do
      Map.put(perms, :admin, Guardian.Permissions.max )
    else
      perms
    end
  end
end
