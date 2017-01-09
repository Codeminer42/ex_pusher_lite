defmodule ExPusherLite.ExAdmin.Organization do
  use ExAdmin.Register

  register_resource ExPusherLite.Organization do
    index do
      selectable_column()

      column :id
      column :name
      column :archived_at

      actions
    end

    show _organization do
      attributes_table do
        row :id
        row :name
        row :slug
        row :archived_at
      end
    end

    form organization do
      inputs do
        input organization, :name
      end
    end
  end
end
