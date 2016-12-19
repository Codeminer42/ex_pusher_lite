defmodule ExPusherLite.ApplicationToken do
  use ExPusherLite.Web, :model

  alias ExPusherLite.Application

  schema "application_tokens" do
    field :token, :string
    field :invalidated_at, Ecto.DateTime

    timestamps()

    belongs_to :application, Application
  end

  @required_fields [:token]
  @optional_fields [:application_id, :invalidated_at]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> generate_uuid(:token)
    |> validate_required(@required_fields)
    |> cast_assoc(:application)
  end

  def create_to(%Application{id: application_id}) do
    changeset(%__MODULE__{}, %{application_id: application_id})
      |> Repo.insert
  end

  def create_to(%{id: application_id}), do: create_to(%Application{id: application_id})
  def create_to(%{application_id: application_id}), do: create_to(%Application{id: application_id})
  def create_to(application_id) when is_binary(application_id) do
    create_to(%Application{id: application_id})
  end

  def get_by(token) do
    from(a in Application,
      join: t in ExPusherLite.ApplicationToken, on: a.id == t.application_id,
      where: t.token == ^token and is_nil(t.invalidated_at))
    |> Repo.one
  end
end
