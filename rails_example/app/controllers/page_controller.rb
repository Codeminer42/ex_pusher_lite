require "net/http"
require "uri"
class PageController < ApplicationController
  def index
    @guardian_token = Rails.cache.fetch("temporary_jwt", expires_in: 2.days) do
      uri = URI.parse("http://#{Rails.application.secrets.pusher_host}/api/sessions")
      response = Net::HTTP.post_form(uri, {"token" => Rails.application.secrets.secret_token})
      JSON.parse(response.body)["jwt"]
    end
  end
end
