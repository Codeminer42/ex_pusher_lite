require "net/http"
require "uri"
class PageController < ApplicationController
  def index
    uri = URI.parse("https://#{Rails.application.secrets.pusher_host}/api/sessions")
    response = Net::HTTP.post_form(uri, {"token" => Rails.application.secrets.secret_token})
    @guardian_token = JSON.parse(response.body)["jwt"]
    Rails.logger.info @guardian_token
  end
end
