defmodule ExPusherLite.Repo.Migrations.CreateUserToken do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :user_id, references(:users), null: false
      add :token, :string, null: false
      add :invalidated_at, :datetime

      timestamps()
    end

    create unique_index(:user_tokens, [:token])

  end
end
