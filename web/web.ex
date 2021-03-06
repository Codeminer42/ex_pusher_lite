defmodule ExPusherLite.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use ExPusherLite.Web, :controller
      use ExPusherLite.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import ExPusherLite.ModelHelpers

      alias ExPusherLite.Repo

      def all do
        Repo.all(__MODULE__)
      end

      def first do
        __MODULE__ |> first(:id) |> Repo.one
      end

      def last do
        __MODULE__ |> last(:id) |> Repo.one
      end
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      use Guardian.Phoenix.Controller

      alias ExPusherLite.Repo
      import Ecto
      import Ecto.Query

      import ExPusherLite.Router.Helpers
      import ExPusherLite.Gettext

      def unauthorized(conn, %{:reason => :forbidden}) do
        changeset = ExPusherLite.UserToken.changeset(%ExPusherLite.UserToken{}, %{})
          |> Ecto.Changeset.add_error(:token, "forbidden")
        conn
          |> put_status(401)
          |> render(ExPusherLite.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ExPusherLite.Router.Helpers
      import ExPusherLite.ErrorHelpers
      import ExPusherLite.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias ExPusherLite.Repo
      import Ecto
      import Ecto.Query
      import ExPusherLite.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
