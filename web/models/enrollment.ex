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
        from e in __MODULE__,
          where: e.user_id == ^user_id and e.organization_id == ^id and e.is_admin == true
      _ ->
        from e in __MODULE__,
          join: o in ExPusherLite.Organization, on: o.id == e.organization_id,
          where: o.slug == ^organization_id and e.user_id == ^user_id and e.is_admin == true
    end
  end
end
