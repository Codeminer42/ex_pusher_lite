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
end
