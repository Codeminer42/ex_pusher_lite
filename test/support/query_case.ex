defmodule ExPusherLite.QueryCase do
  @moduledoc """
  This module defines the test case to be used by
  query tests.

  You may define functions here to be used as helpers in
  your query tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExPusherLite.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ExPusherLite.Factory
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
