defmodule ExPusherLite.ExAdmin.Application do
  use ExAdmin.Register

  alias ExPusherLite.Repo

  register_resource ExPusherLite.Application do
    index do
      selectable_column()

      column :id
      column :name
      column :archived_at

      actions()
    end

    show application do
      attributes_table do
        row :id
        row :name
        row :app_key
        row :app_secret
        row :archived_at
      end

      panel "Owned by" do
        application = application |> Repo.preload(ownerships: [:organization])
        table_for application.ownerships do
          column :id, fn(ownership) -> a "Ownership Id: #{ownership.id}", href: admin_resource_path(ownership, :show) end
          column :name, fn(ownership) -> a ownership.organization.name, href: admin_resource_path(ownership.organization, :show) end
        end
      end
    end

    form application do
      inputs do
        input application, :name
        input application, :app_key
        input application, :app_secret
      end
    end
  end
end
