defmodule ExPusherLite.UserToken do
  use ExPusherLite.Web, :model

  alias ExPusherLite.{User, Enrollment}

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
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :access, perms: get_perms(user, params))
    jwt
  end

  def valid(query) do
    from a in query,
    where: is_nil(a.invalidated_at)
  end

  defp get_perms(%User{}, %{test: true}) do
    %{ default: Guardian.Permissions.max, admin: Guardian.Permissions.max }
  end

  defp get_perms(%User{} = user, _params) do
    find_admin_enrollment(user.id) |> put_permissions
  end

  defp find_admin_enrollment(user_id) do
    user_id
    |> Enrollment.by_user_id
    |> Enrollment.admin
    |> Ecto.Query.first
    |> Repo.one
  end

  defp put_permissions(%Enrollment{}) do
    Map.put(perms(), :admin, Guardian.Permissions.max)
  end
  defp put_permissions(_) do
    perms()
  end

  defp perms do
    %{ default: Guardian.Permissions.max }
  end
end
