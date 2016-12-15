defmodule ExPusherLite.Organization do
  use ExPusherLite.Web, :model

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :archived_at, Ecto.DateTime

    timestamps()

    has_many :enrollments, ExPusherLite.Enrollment, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:enrollments, :user]

    has_many :ownerships, ExPusherLite.Ownership, on_delete: :delete_all, on_replace: :delete
    has_many :applications, through: [:ownerships, :application]
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
