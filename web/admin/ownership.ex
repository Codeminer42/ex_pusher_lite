defmodule ExPusherLite.ExAdmin.Ownership do
  use ExAdmin.Register

  alias ExPusherLite.{Organization, Application}

  query do
    %{all: [preload: [:organization, :application]]}
  end

  register_resource ExPusherLite.Ownership do
    index do
      selectable_column()

      column :id
      column :organization, fn(ownership) -> ownership.organization.name end
      column :application, fn(ownership) -> ownership.application.name end
      column :is_owned, toggle: true

      actions
    end

    show _ do
      attributes_table do
        row :id
        row :organization, fn(ownership) -> ownership.organization.name end
        row :application, fn(ownership) -> ownership.application.name end
        row :is_owned, toggle: true
      end
    end

    form ownership do
      inputs do
        input ownership, :organization, collection: Organization.all
        input ownership, :application, collection: Application.all
        input ownership, :is_owned
      end
    end
  end
end
