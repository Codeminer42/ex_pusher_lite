defmodule ExPusherLite.EmailHelpers do
  alias Coherence.Config
  require Logger

  def site_name, do: Config.site_name(inspect Config.module)

  def first_name(name) do
    case String.split(name, " ") do
      [first_name | _] -> first_name
      _ -> name
    end
  end

  def user_email(user) do
    {user.name, user.email}
  end

  def from_email do
    {Config.email_from_name, Config.email_from_email}
  end
end
