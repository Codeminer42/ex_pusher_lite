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

      alias ExPusherLite.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ExPusherLite.Router.Helpers

      import ExPusherLite.Factory

      # The default endpoint for testing
      @endpoint ExPusherLite.Endpoint

      def guardian_sign_in(%Plug.Conn{} = conn, user, token \\ nil) do
        user  = user  || create_admin_user
        token = token || create_admin_token(user)
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(token)

        build_conn()
          |> assign(:test_user, user)
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
