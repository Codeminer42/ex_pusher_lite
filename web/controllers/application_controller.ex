defmodule ExPusherLite.ApplicationController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.{Enrollment, Ownership, Application, Organization}

  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.EnsurePermissions, [ handler: __MODULE__, admin: [:api_admin] ]
  plug :check_organization_enrollment_and_admin_privileges

  def index(conn, %{"organization_id" => organization_id}, _current_user, _claims) do
    applications = organization_id
      |> Application.by_organization_id_or_slug
      |> Repo.all

    render(conn, "index.json", applications: applications)
  end

  def create(conn, %{"organization_id" => organization_id, "application" => application_params}, current_user, claims) when is_binary(organization_id) do
    id = case Integer.parse(organization_id) do
           {id, ""} -> id
           _        -> Repo.get_by(Organization, slug: organization_id).id
         end
    create(conn, %{"organization_id" => id, "application" => application_params}, current_user, claims)
  end

  def create(conn, %{"organization_id" => organization_id, "application" => application_params}, _current_user, _claims) when is_integer(organization_id) do
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

  def show(conn, %{"organization_id" => organization_id, "id" => id}, _current_user, _claims) do
    application = load_application(organization_id, id)

    render(conn, "show.json", application: application)
  end

  def update(conn, %{"organization_id" => organization_id, "id" => id, "application" => application_params}, _current_user, _claims) do
    application = load_application(organization_id, id)
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

  def delete(conn, %{"organization_id" => organization_id, "id" => id}, _current_user, _claims) do
    application = load_application(organization_id, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(application)

    send_resp(conn, :no_content, "")
  end

  def event(conn, %{"organization_id" => organization_id, "application_id" => id, "event" => event} = params, _current_user, _claims) do
    application = load_application(organization_id, id)
    room_name   = ExPusherLite.UserSocket.generate_id(application.app_key, params["topic"] || "general")

    if event == "presence_list" do
      render(conn, "presence_list.json", list: ExPusherLite.Presence.list(room_name))
    else
      ExPusherLite.Endpoint.broadcast_from(self(), room_name, event, clean_payload(params))
      send_resp(conn, :no_content, "")
    end
  end

  defp check_organization_enrollment_and_admin_privileges(conn, _) do
    %{params: %{"organization_id" => organization_id}, private: %{guardian_default_resource: current_user}} = conn
    if Enrollment.by_organization_id_or_slug_and_user(organization_id, current_user.id) |> Repo.one do
      conn
    else
      conn
        |> put_status(401)
        |> halt
    end
  end

  defp load_application(organization_id, id) do
    organization_id
      |> Application.by_organization_id_or_slug
      |> Application.by_id_or_key(id)
      |> Repo.one!
  end

  defp clean_payload(params) do
    Map.drop(params, ["organization_id", "application_id", "event", "topic"])
  end
end
