defmodule ExPusherLite.Organization do
  use ExPusherLite.Web, :model

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :archived_at, Ecto.DateTime

    timestamps()
  end

  @required_fields [:name, :slug]
  @optional_fields [:archived_at]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> generate_slug(:name, :slug)
    |> validate_required(@required_fields)
  end
end
