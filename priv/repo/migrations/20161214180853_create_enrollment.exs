defmodule ExPusherLite.Repo.Migrations.CreateEnrollment do
  use Ecto.Migration

  def change do
    create table(:enrollments) do
      add :user_id, references(:users)
      add :organization_id, references(:organizations)
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:enrollments, [:user_id, :organization_id])

  end
end
