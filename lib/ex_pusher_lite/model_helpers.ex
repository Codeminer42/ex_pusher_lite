import Ecto.Changeset

defmodule ExPusherLite.ModelHelpers do
  def generate_uuid(struct, field) do
    if get_field(struct, field) do
      struct
    else
      put_change(struct, field, UUID.uuid1())
    end
  end
end
