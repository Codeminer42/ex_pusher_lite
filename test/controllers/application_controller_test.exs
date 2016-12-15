defmodule ExPusherLite.ApplicationControllerTest do
  use ExPusherLite.ConnCase

  alias ExPusherLite.{Organization, Application, Ownership}
  @valid_attrs_organization %{name: "Acme Inc."}
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, organization} = Organization.changeset(%Organization{}, @valid_attrs_organization) |> Repo.insert
    {:ok, conn: put_req_header(conn, "accept", "application/json"), organization: organization}
  end

  test "lists all entries on index", %{conn: conn, organization: organization} do
    conn = get conn, organization_application_path(conn, :index, organization)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn, organization: organization} do
    {:ok, ownership} = Ownership.changeset(%Ownership{}, %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true}) |> Repo.insert
    application = ownership.application
    conn = get conn, organization_application_path(conn, :show, organization, application)
    assert json_response(conn, 200)["data"] == %{"id" => application.id,
      "name" => application.name,
      "app_key" => application.app_key,
      "app_secret" => application.app_secret,
      "archived_at" => application.archived_at}
  end

  test "renders page not found when id is nonexistent", %{conn: conn, organization: organization} do
    assert_error_sent 404, fn ->
      get conn, organization_application_path(conn, :show, organization, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, organization: organization} do
    conn = post conn, organization_application_path(conn, :create, organization), application: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Application, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    conn = post conn, organization_application_path(conn, :create, organization), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, organization: organization} do
    {:ok, ownership} = Ownership.changeset(%Ownership{}, %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true}) |> Repo.insert
    application = ownership.application
    conn = put conn, organization_application_path(conn, :update, organization, application), application: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Application, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    {:ok, ownership} = Ownership.changeset(%Ownership{}, %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true}) |> Repo.insert
    application = ownership.application
    conn = put conn, organization_application_path(conn, :update, organization, application), application: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, organization: organization} do
    {:ok, ownership} = Ownership.changeset(%Ownership{}, %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true}) |> Repo.insert
    application = ownership.application
    conn = delete conn, organization_application_path(conn, :delete, organization, application)
    assert response(conn, 204)
    refute Repo.get(Application, application.id)
    refute Repo.get(Ownership, ownership.id)
  end
end
