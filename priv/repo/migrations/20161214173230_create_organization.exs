defmodule ExPusherLite.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :slug, :string
      add :archived_at, :datetime

      timestamps()
    end

    create unique_index(:organizations, [:slug])

  end
end
