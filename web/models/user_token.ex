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
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :access, get_claims(user, params))
    jwt
  end

  defp get_claims(%User{} = user, params) do
    api_perms     = unless params["channel"], do: [:read, :write], else: []
    channel_perms = if params["channel"],     do: [:read, :write], else: []
    admin_perms   = if user.is_root,          do: [:read, :write], else: []
    ttl           = if params["channel"],     do: 5, else: 2 # days
    Guardian.Claims.app_claims
      |> Map.put("api", api_perms)
      |> Map.put("channel", channel_perms)
      |> Map.put("admin", admin_perms)
      |> Guardian.Claims.ttl({ttl, :days})
  end
end
