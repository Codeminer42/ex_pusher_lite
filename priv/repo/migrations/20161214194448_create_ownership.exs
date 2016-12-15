defmodule ExPusherLite.Repo.Migrations.CreateOwnership do
  use Ecto.Migration

  def change do
    create table(:ownerships) do
      add :organization_id, references(:organizations)
      add :application_id, references(:applications)
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:ownerships, [:organization_id, :application_id])

  end
end
