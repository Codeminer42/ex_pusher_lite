defmodule ExPusherLite.Application do
  use ExPusherLite.Web, :model

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
end
