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

      alias ExPusherLite.{Repo, User}
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ExPusherLite.Router.Helpers

      # The default endpoint for testing
      @endpoint ExPusherLite.Endpoint
      @valid_admin_user_attrs %{name: "John Wayne", email: "john@wayne.org", password: "secret", password_confirmation: "secret"}

      def admin_user_and_token(params \\ @valid_admin_user_attrs) do
        %User{}
          |> User.changeset(params)
          |> Repo.insert!
          |> User.token_changeset
          |> Repo.insert!
      end

      def guardian_sign_in(%Plug.Conn{} = conn, user) do
        {:ok, jwt, _full_claims} = user || admin_user_and_token(@valid_admin_user_attrs)
          |> Guardian.encode_and_sign

        build_conn()
          |> put_req_header("authorization", "Bearer #{jwt}")
      end
      def guardian_sign_in(%Plug.Conn{} = conn), do: guardian_sign_in(conn, nil)
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
