defmodule ExPusherLite.Enrollment do
  use ExPusherLite.Web, :model

  schema "enrollments" do
    field :is_admin, :boolean, default: false

    timestamps()

    belongs_to :organization, ExPusherLite.Organization
    belongs_to :user, ExPusherLite.User
  end

  @required_fields []
  @optional_fields [:organization_id, :user_id, :is_admin]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:organization)
    |> cast_assoc(:user)
  end

  def by_organization_id_or_slug_and_user(organization_id, user_id) do
    case Integer.parse(organization_id) do
      {id, _} ->
        by_user_id(user_id) |> by_organization_id(id) |> admin
      _ ->
        by_user_id(user_id) |> by_organization_slug(organization_id) |> admin
    end
  end

  def by_organization_id(query \\ __MODULE__, id) do
    from e in query,
      where: e.organization_id == ^id
  end

  def by_organization_slug(query \\ __MODULE__, slug) do
    from e in query,
      join: o in ExPusherLite.Organization,
      on: o.id == e.organization_id,
      where: o.slug == ^slug
  end

  def by_user_id(query \\ __MODULE__, user_id) do
    from e in query,
      where: e.user_id == ^user_id
  end

  def admin(query \\ __MODULE__) do
    from e in query,
      where: e.is_admin == true
  end
end
