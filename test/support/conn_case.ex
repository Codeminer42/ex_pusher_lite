defmodule ExPusherLite.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias ExPusherLite.{Repo, User, Enrollment, Ownership}
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ExPusherLite.Router.Helpers

      # The default endpoint for testing
      @endpoint ExPusherLite.Endpoint
      @valid_admin_user_attrs %{name: "John Wayne", email: "john@wayne.org", password: "secret", password_confirmation: "secret", is_root: false}

      def create_admin_user(params \\ @valid_admin_user_attrs) do
        %User{}
          |> User.changeset(params)
          |> Repo.insert!
      end

      def create_admin_token(admin_user) do
        admin_user
          |> User.token_changeset
          |> Repo.insert!
      end

      def guardian_sign_in(%Plug.Conn{} = conn, user, token \\ nil) do
        user  = user  || create_admin_user
        token = token || create_admin_token(user)
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(token)

        build_conn()
          |> assign(:test_user, user)
          |> put_req_header("authorization", "Bearer #{jwt}")
      end
      def guardian_sign_in(%Plug.Conn{} = conn), do: guardian_sign_in(conn, nil)

      def build_organization(test_user) do
        enrollment = Enrollment.changeset(%Enrollment{},
          %{user_id: test_user.id, organization: %{name: "Acme Inc."}, is_admin: true})
            |> Repo.insert!
        enrollment.organization
      end

      def build_application(organization) do
        ownership = Ownership.changeset(%Ownership{},\
          %{organization_id: organization.id, application: %{name: "Test App"}, is_owned: true})
            |> Repo.insert!
        application = ownership.application
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExPusherLite.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ExPusherLite.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
