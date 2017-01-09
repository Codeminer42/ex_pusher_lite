defmodule ExPusherLite.Router do
  use ExPusherLite.Web, :router
  use Coherence.Router
  use ExAdmin.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :session do
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :protected_root do
    plug ExPusherLite.Plugs.Authorized
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :guardian do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", ExPusherLite do
    pipe_through [ :browser, :session ]
    coherence_routes()
  end

  scope "/", ExPusherLite do
    pipe_through [ :browser, :protected ]
    coherence_routes :protected
  end

  scope "/", ExPusherLite do
    pipe_through [ :browser, :session ] # Use the default browser stack

    get "/", PageController, :index
    post "/", PageController, :create
  end

  scope "/", ExPusherLite do
    pipe_through [ :browser, :protected ]
  end

  scope "/admin", ExAdmin do
    pipe_through [ :browser ,:protected, :protected_root]

    admin_routes()
  end

  scope "/api", ExPusherLite do
    pipe_through :api

    resources "/sessions", SessionController, only: [:create], as: "sign_in"
  end

  scope "/api", ExPusherLite do
    pipe_through [:api, :guardian]

    resources "/organizations", OrganizationController, except: [:new, :edit] do
      resources "/applications", ApplicationController, except: [:new, :edit] do
        post "/event/:event", ApplicationController, :event, as: :event
      end
    end
  end
end
