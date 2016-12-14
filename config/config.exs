# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_pusher_lite,
  ecto_repos: [ExPusherLite.Repo]

# Configures the endpoint
config :ex_pusher_lite, ExPusherLite.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tXXHbCzpHhZEcsuhsBitVDM8go5xk9carWDcXGAt8PqrEKL6gW9NSUYwySQLIXNI",
  render_errors: [view: ExPusherLite.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExPusherLite.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: ExPusherLite.User,
  repo: ExPusherLite.Repo,
  module: ExPusherLite,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:invitable, :confirmable, :rememberable, :authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :registerable]

config :coherence, ExPusherLite.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%

config :ex_admin,
  repo: ExPusherLite.Repo,
  module: ExPusherLite,
  modules: [
    ExPusherLite.ExAdmin.Dashboard,
    ExPusherLite.ExAdmin.User
  ]

config :xain, :after_callback, {Phoenix.HTML, :raw}


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
