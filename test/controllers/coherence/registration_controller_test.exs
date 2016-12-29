defmodule ExPusherLite.RegistrationController do
  use ExPusherLite.ConnCase

  setup %{conn: conn} do
    user = create_admin_user
    conn = assign conn, :current_user, user
    {:ok, conn: conn, user: user}
  end

  describe "show" do
    test "can visit show registraion page", %{conn: conn, user: user} do
      token = create_admin_token(user)
      organization = build_organization(user)
      conn = get conn, registration_path(conn, :show)
      assert html_response(conn, 200)
      assert conn.private[:phoenix_template] == "show.html"
      assert Enum.at(conn.assigns.user.organizations, 0).name == organization.name
      assert Enum.at(conn.assigns.user.tokens, 0).token == token.token
    end
  end

  describe "edit" do
    test "can visit edit registraion page", %{conn: conn} do
      conn = get conn, registration_path(conn, :edit)
      assert html_response(conn, 200)
      assert conn.private[:phoenix_template] == "edit.html"
    end
  end

  describe "create" do
    test "can create new registration with valid params", %{conn: conn} do
      conn = assign conn, :current_user, nil
      enroll_params = %{"is_admin" => "true", "organization" => %{"name" => "Acme Inc."}}
      params = %{"registration" => %{"name" => "John Doe", "email" => "john.doe@example.com", "password" => "123123", "enrollments" => %{"0" => enroll_params}}}
      conn = post conn, registration_path(conn, :create), params
      assert conn.private[:phoenix_flash] == %{"info" => "Confirmation email sent."}
      assert html_response(conn, 302)
      assert ExPusherLite.Organization.last.name == "Acme Inc."
    end

    test "can not register with invalid params", %{conn: conn} do
      conn = assign conn, :current_user, nil
      params = %{"registration" => %{}}
      conn = post conn, registration_path(conn, :create), params
      errors = conn.assigns.changeset.errors
      assert errors[:password] == {"can't be blank", []}
      assert errors[:email] == {"can't be blank", []}
      assert errors[:name] == {"can't be blank", []}
    end
  end

  describe "update" do
    test "can update registration", %{conn: conn} do
      params = %{"registration" => %{password: "123123", password_confirmation: "123123"}}
      conn = put conn, registration_path(conn, :update), params
      assert conn.private[:phoenix_flash] == %{"info" => "Account updated successfully."}
      assert html_response(conn, 302)
    end

    test "can not update registration without valid password", %{conn: conn} do
      params = %{"registration" => %{password: "abcdef", password_confirmation: "123123"}}
      conn = put conn, registration_path(conn, :update), params
      errors = conn.assigns.changeset.errors
      assert errors[:password_confirmation] == {"does not match confirmation", []}
    end
  end
end
