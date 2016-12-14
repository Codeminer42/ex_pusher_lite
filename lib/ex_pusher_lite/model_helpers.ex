defmodule ExPusherLite.ModelHelpers do
  import Ecto.Changeset

  def generate_uuid(struct, field) do
    if get_field(struct, field) do
      struct
    else
      put_change(struct, field, UUID.uuid1())
    end
  end

  def generate_slug(struct, from, to) do
    if get_field(struct, to) do
      struct
    else
      slug = get_field(struct, from)
        |> Slugger.slugify_downcase
      put_change(struct, to, slug)
    end
  end
end
