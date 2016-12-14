defmodule ExPusherLite.User do
  use ExPusherLite.Web, :model
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    coherence_schema

    timestamps

    has_many :enrollments, ExPusherLite.Enrollment, on_delete: :delete_all, on_replace: :delete
    has_many :organizations, through: [:enrollments, :organization]
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields)
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end
end
