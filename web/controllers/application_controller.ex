defmodule ExPusherLite.ApplicationController do
  use ExPusherLite.Web, :controller

  alias ExPusherLite.{Enrollment, Ownership, Application}

  plug Guardian.Plug.EnsureAuthenticated
  plug :check_organization_enrollment_and_admin_privileges

  def index(conn, %{"organization_id" => organization_id}, _current_token, _claims) do
    applications = organization_id
      |> Application.by_organization_id_or_slug
      |> Repo.all

    render(conn, "index.json", applications: applications)
  end

  def create(conn, %{"organization_id" => organization_id, "application" => application_params}, _current_token, _claims) do
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

  def show(conn, %{"organization_id" => organization_id, "id" => id}, _current_token, _claims) do
    application = organization_id
      |> Application.by_organization_id_or_slug
      |> Application.by_id_or_key(id)
      |> Repo.one!

    render(conn, "show.json", application: application)
  end

  def update(conn, %{"organization_id" => organization_id, "id" => id, "application" => application_params}, _current_token, _claims) do
    application = organization_id
      |> Application.by_organization_id_or_slug
      |> Application.by_id_or_key(id)
      |> Repo.one!
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

  def delete(conn, %{"organization_id" => organization_id, "id" => id}, _current_token, _claims) do
    application = organization_id
      |> Application.by_organization_id_or_slug
      |> Application.by_id_or_key(id)
      |> Repo.one!

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(application)

    send_resp(conn, :no_content, "")
  end

  def event(conn, %{"organization_id" => organization_id, "application_id" => id} = params, _current_token, _claims) do
    application = organization_id
      |> Application.by_organization_id_or_slug
      |> Application.by_id_or_key(id)
      |> Repo.one!

    # TODO hard coding the channel payload, but we want to receive arbitrary JSON, convert to Map and broadcast that
    event   = params["event"] || "new_message"
    name    = params["name"] || "Robot"
    message = params["message"] || "Hello World!"

    ExPusherLite.Endpoint.broadcast_from(self(),
      "lobby:#{application.app_key}", event, %{name: name, message: message})

    send_resp(conn, :no_content, "")
  end

  defp check_organization_enrollment_and_admin_privileges(conn, _) do
    %{params: %{"organization_id" => organization_id}, private: %{guardian_default_resource: current_token}} = conn
    if Enrollment.by_organization_id_or_slug_and_user(organization_id, current_token.user.id) |> Repo.one do
      conn
    else
      conn
        |> put_status(401)
        |> halt
    end
  end


end
