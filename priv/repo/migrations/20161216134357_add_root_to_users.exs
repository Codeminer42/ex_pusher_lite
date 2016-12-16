defmodule ExPusherLite.Repo.Migrations.AddRootToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_root, :boolean, default: false, null: false
    end
  end
end
