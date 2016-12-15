defmodule ExPusherLite.Ownership do
  use ExPusherLite.Web, :model

  schema "ownerships" do
    field :is_owned, :boolean, default: false

    timestamps()

    belongs_to :organization, ExPusherLite.Organization
    belongs_to :application, ExPusherLite.Application
  end

  @required_fields [:organization_id, :application_id]
  @optional_fields [:is_owned]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:organization)
    |> cast_assoc(:application)
  end
end
