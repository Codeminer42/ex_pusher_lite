defmodule ExPusherLite.Repo.Migrations.CreateApplication do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :name, :string
      add :app_key, :string
      add :app_secret, :string
      add :archived_at, :datetime

      timestamps()
    end

    create unique_index(:applications, [:app_key])
    create index(:applications, [:app_secret])
  end
end
