use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"{Rx[w&Dbeo4>~gD/i;AhW5c`iJ<2Hv5VC__>oGOgV6;N*jS*]T2lPa*|**2yh)|1"
end

environment :prod do
  plugin Releases.Plugin.LinkConfig
  set include_erts: true
  set include_src: false
  set cookie: :"4r*S=kf53w4V1w@$=;??/]hYz>xUh81_9TFHhMx:^DBu1<o<kjYrRZ2i6|QZb}09"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :ex_pusher_lite do
  set version: current_version(:ex_pusher_lite)

  set applications: [
    ex_pusher_lite: :permanent
  ]
end

