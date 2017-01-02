defmodule ExPusherLite.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
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
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias ExPusherLite.{Repo, UserSocket}
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ExPusherLite.Factory

      # The default endpoint for testing
      @endpoint ExPusherLite.Endpoint

      def connect_socket_and_join_channel(app_key, user_id, uid, topic \\ "general") do
        {:ok, _, socket} = UserSocket.generate_id(app_key, uid)
          |> socket(%{app_key: app_key, user_id: user_id, uid: uid})
          |> subscribe_and_join(ExPusherLite.LobbyChannel, UserSocket.generate_id(app_key, topic))
        socket
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExPusherLite.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ExPusherLite.Repo, {:shared, self()})
    end

    :ok
  end
end
