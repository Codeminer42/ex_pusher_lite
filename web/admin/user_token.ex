defmodule ExPusherLite.ExAdmin.UserToken do
  use ExAdmin.Register

  query do
    %{all: [preload: [:user]]}
  end

  register_resource ExPusherLite.UserToken do
    index do
      selectable_column

      column :id
      column :user, fn(user_token) -> user_token.user.name end
      column :token
      column :invalidated_at

      actions
    end

    show _user_token do
      attributes_table do
        row :id
        row :owner, fn(user_token) ->
          a user_token.user.name, href: admin_resource_path(user_token.user, :show)
        end
        row :token
        row :invalidated_at
      end
    end

    form user_token do
      inputs do
        input user_token, :token
        input user_token, :invalidated_at
      end
    end
  end
end

