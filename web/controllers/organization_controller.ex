defmodule ExPusherLite.OrganizationController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.{Organization, Enrollment}

  plug Guardian.Plug.EnsureAuthenticated

  def index(conn, _params, current_token, _claims) do
    organizations = current_token.user
      |> build_query
      |> Repo.all

    render(conn, "index.json", organizations: organizations)
  end

  def create(conn, %{"organization" => organization_params}, current_token, _claims) do
    changeset = Enrollment.changeset(%Enrollment{},
      %{user_id: current_token.user.id, organization: organization_params, is_admin: true})

    case Repo.insert(changeset) do
      {:ok, enrollment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", organization_path(conn, :show, enrollment.organization))
        |> render("show.json", organization: enrollment.organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_token, _claims) do
    organization = current_token.user
      |> build_query
      |> Repo.get!(id)

    if organization do
      render(conn, "show.json", organization: organization)
    else
      send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"id" => id, "organization" => organization_params}, current_token, _claims) do
    organization = current_token.user
      |> build_query
      |> Repo.get!(id)
    changeset = Organization.changeset(organization, organization_params)

    case Repo.update(changeset) do
      {:ok, organization} ->
        render(conn, "show.json", organization: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_token, _claims) do
    organization = current_token.user
      |> build_query
      |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    send_resp(conn, :no_content, "")
  end

  defp build_query(current_user) do
    if current_user.is_root do
      Organization
    else
      from o in Organization,
        join: e in Enrollment, on: e.organization_id == o.id,
        where: e.user_id == ^current_user.id
    end
  end
end
