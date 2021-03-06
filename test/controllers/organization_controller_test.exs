defmodule ExPusherLite.OrganizationControllerTest do
  use ExPusherLite.ConnCase

  alias ExPusherLite.Organization
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{name: ""}

  setup %{conn: _conn} do
    conn = build_conn()
      |> guardian_sign_in
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, organization_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: %{assigns: %{test_user: test_user}} = conn} do
    organization = build_organization(test_user)
    conn = get conn, organization_path(conn, :show, organization)
    assert json_response(conn, 200)["data"] == %{"id" => organization.id,
      "name" => organization.name,
      "slug" => organization.slug,
      "archived_at" => organization.archived_at}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, organization_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, organization_path(conn, :create), organization: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Organization, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, organization_path(conn, :create), organization: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: %{assigns: %{test_user: test_user}} = conn} do
    organization = build_organization(test_user)
    conn = put conn, organization_path(conn, :update, organization), organization: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Organization, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: %{assigns: %{test_user: test_user}} = conn} do
    organization = build_organization(test_user)
    conn = put conn, organization_path(conn, :update, organization), organization: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: %{assigns: %{test_user: test_user}} = conn} do
    organization = build_organization(test_user)
    conn = delete conn, organization_path(conn, :delete, organization)
    assert response(conn, 204)
    refute Repo.get(Organization, organization.id)
  end
end
