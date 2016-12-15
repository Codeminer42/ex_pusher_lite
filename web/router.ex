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
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", ExPusherLite do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", ExPusherLite do
    pipe_through :protected

    # get "/", PageController, :index
  end

  scope "/admin", ExAdmin do
    pipe_through :protected

    admin_routes
  end

  # Other scopes may use custom stacks.
  scope "/api", ExPusherLite do
    pipe_through :api

    resources "/organizations", OrganizationController, except: [:new, :edit] do
      resources "/applications", ApplicationController, except: [:new, :edit]
    end
  end
end
