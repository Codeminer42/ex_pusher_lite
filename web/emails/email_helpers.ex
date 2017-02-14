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
    case Config.email_from do
      nil ->
        Logger.error ~s|Need to configure :coherence, :email_from_name, "Name", and :email_from_email, "me@example.com"|
        nil
      {name, email} = email_tuple ->
        if is_nil(name) or is_nil(email) do
          Logger.error ~s|Need to configure :coherence, :email_from_name, "Name", and :email_from_email, "me@example.com"|
          nil
        else
          email_tuple
        end
    end
  end
end
