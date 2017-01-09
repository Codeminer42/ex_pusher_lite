defmodule ExPusherLite.ExAdmin.Enrollment do
  use ExAdmin.Register

  alias ExPusherLite.{Organization, User}

  query do
    %{all: [preload: [:organization, :user]]}
  end

  register_resource ExPusherLite.Enrollment do
    index do
      selectable_column()

      column :id
      column :organization, fn(enrollment) -> enrollment.organization.name end
      column :user, fn(enrollment) -> enrollment.user.name end
      column :is_admin, toggle: true

      actions
    end

    show _ do
      attributes_table do
        row :id
        row :organization, fn(enrollment) -> enrollment.organization.name end
        row :user, fn(enrollment) -> enrollment.user.name end
        row :is_admin, toggle: true
      end
    end

    form enrollment do
      inputs do
        input enrollment, :organization, collection: Organization.all
        input enrollment, :user, collection: User.all
        input enrollment, :is_admin
      end
    end
  end
end
