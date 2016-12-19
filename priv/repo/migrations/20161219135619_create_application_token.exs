defmodule ExPusherLite.Repo.Migrations.CreateApplicationToken do
  use Ecto.Migration

  def change do
    create table(:application_tokens) do
      add :application_id, references(:applications), null: false
      add :token, :string, null: false
      add :invalidated_at, :datetime

      timestamps()
    end

    create unique_index(:application_tokens, [:token])

  end
end
