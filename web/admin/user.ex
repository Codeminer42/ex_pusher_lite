defmodule ExPusherLite.ExAdmin.User do
  use ExAdmin.Register

  alias ExPusherLite.Repo

  register_resource ExPusherLite.User do
    index do
      selectable_column

      column :id
      column :name
      column :email
      column :last_sign_in_at

      actions
    end

    show user do
      attributes_table do
        row :id
        row :name
        row :email
        row :reset_password_token
        row :reset_password_sent_at
        row :locked_at
        row :unlock_token
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
      end

      panel "Enrolled in" do
        user = user |> Repo.preload(enrollments: [:organization])
        table_for user.enrollments do
          column :id, fn(enrollment) -> a "Enrollment Id: #{enrollment.id}", href: admin_resource_path(enrollment, :show) end
          column :name, fn(enrollment) -> a enrollment.organization.name, href: admin_resource_path(enrollment, :show) end
        end
      end
    end

    form user do
      inputs do
        input user, :name
        input user, :email
        input user, :password, type: :password
        input user, :password_confirmation, type: :password
      end
    end
  end
end
