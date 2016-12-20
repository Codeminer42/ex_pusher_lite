defmodule ExPusherLite.Application do
  use ExPusherLite.Web, :model

  alias ExPusherLite.{Ownership, Organization}

  schema "applications" do
    field :name, :string
    field :app_key, :string
    field :app_secret, :string
    field :archived_at, Ecto.DateTime

    timestamps()

    has_many :ownerships, ExPusherLite.Ownership, on_delete: :delete_all, on_replace: :delete
    has_many :organizations, through: [:ownerships, :organization]
  end

  @required_fields [:name, :app_key, :app_secret]
  @optional_fields [:archived_at]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> generate_uuid(:app_key)
    |> generate_uuid(:app_secret)
    |> validate_required(@required_fields)
  end

  def by_organization_id_or_slug(organization_id) do
    case Integer.parse(organization_id) do
      {id, ""} ->
        from a in __MODULE__,
          join: w in Ownership, on: w.application_id == a.id,
          join: o in Organization, on: w.organization_id == o.id,
          where: o.id == ^id and w.is_owned == true
      _ ->
        from a in __MODULE__,
          join: w in Ownership, on: w.application_id == a.id,
          join: o in Organization, on: w.organization_id == o.id,
          where: o.slug == ^organization_id and w.is_owned == true
    end
  end

  def by_id_or_key(queryable, application_id) do
    case Integer.parse(application_id) do
      {id, ""} ->
        queryable |> where([a], a.id == ^id)
      _ ->
        queryable |> where([a], a.app_key == ^application_id)
    end
  end
end
