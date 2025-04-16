# frozen_string_literal: true

module AppHost
  def self.host
    if ENV["HEROKU_PR_NUMBER"].present?
      "#{ENV.fetch("HEROKU_APP_NAME")}.herokuapp.com"
    else
      ENV.fetch("APP_HOST", "localhost")
    end
  end
end
