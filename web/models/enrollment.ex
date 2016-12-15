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
end
