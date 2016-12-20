defmodule ExPusherLite.ApplicationController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.{Ownership, Organization, Application}

  plug Guardian.Plug.EnsureAuthenticated

  def index(conn, %{"organization_id" => organization_id}) do
    applications = organization_id |> build_query |> Repo.all

    render(conn, "index.json", applications: applications)
  end

  def create(conn, %{"organization_id" => organization_id, "application" => application_params}) do
    changeset = Ownership.changeset(%Ownership{},
      %{organization_id: organization_id, application: application_params, is_owned: true})

    case Repo.insert(changeset) do
      {:ok, ownership} ->
        application = ownership.application
        conn
        |> put_status(:created)
        |> put_resp_header("location", organization_application_path(conn, :show, organization_id, application))
        |> render("show.json", application: application)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"organization_id" => organization_id, "id" => id}) do
    application = organization_id |> build_query |> Repo.get!(id)
    render(conn, "show.json", application: application)
  end

  def update(conn, %{"organization_id" => organization_id, "id" => id, "application" => application_params}) do
    application = organization_id |> build_query |> Repo.get!(id)
    changeset = Application.changeset(application, application_params)

    case Repo.update(changeset) do
      {:ok, application} ->
        render(conn, "show.json", application: application)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"organization_id" => organization_id, "id" => id}) do
    application = organization_id |> build_query |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(application)

    send_resp(conn, :no_content, "")
  end

  defp build_query(organization_id) do
    case Integer.parse(organization_id) do
      {id, _} ->
        from a in Application,
          join: w in Ownership, on: w.application_id == a.id,
          join: o in Organization, on: w.organization_id == o.id,
          where: o.id == ^id
      :error ->
        from a in Application,
          join: w in Ownership, on: w.application_id == a.id,
          join: o in Organization, on: w.organization_id == o.id,
          where: o.slug == ^organization_id
    end
  end

end
