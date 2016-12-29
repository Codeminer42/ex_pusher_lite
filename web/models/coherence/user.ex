defmodule ExPusherLite.User do
  use ExPusherLite.Web, :model
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :is_root, :boolean, null: false, default: false
    coherence_schema

    timestamps

    has_many :tokens, ExPusherLite.UserToken, on_delete: :delete_all, on_replace: :delete
    has_many :enrollments, ExPusherLite.Enrollment, on_delete: :delete_all, on_replace: :delete
    has_many :organizations, through: [:enrollments, :organization]
  end

  def changeset(model, %{"enrollments" => _} = params) do
    create_changeset(model, params)
      |> cast_assoc(:enrollments)
  end

  def changeset(model, params) do
    create_changeset(model, params)
  end

  defp create_changeset(model, params) do
    model
    |> cast(params, [:name, :email, :is_root] ++ coherence_fields)
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def token_changeset(%__MODULE__{id: user_id}) do
    %ExPusherLite.UserToken{}
      |> ExPusherLite.UserToken.changeset(%{user_id: user_id})
  end

  def token_changeset(%{id: user_id}), do: token_changeset(%__MODULE__{id: user_id})
  def token_changeset(%{user_id: user_id}), do: token_changeset(%__MODULE__{id: user_id})
  def token_changeset(user_id) when is_binary(user_id) do
    token_changeset(%__MODULE__{id: user_id})
  end
end
