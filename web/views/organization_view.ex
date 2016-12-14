defmodule ExPusherLite.OrganizationView do
  use ExPusherLite.Web, :view

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, ExPusherLite.OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, ExPusherLite.OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    %{id: organization.id,
      name: organization.name,
      slug: organization.slug,
      archived_at: organization.archived_at}
  end
end
