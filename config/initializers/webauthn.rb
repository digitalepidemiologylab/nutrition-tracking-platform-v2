# frozen_string_literal: true

require "app_host"

protocol = ENV.fetch("APP_PROTOCOL", "http")
host = AppHost.host
port = ENV.fetch("APP_PORT", 80).to_i + ENV["TEST_ENV_NUMBER"].to_i

if Rails.env.test? && ENV["SELENIUM_REMOTE_HOST"].present?
  protocol = "https"
  host = "host.docker.internal"
  port = 4000 + ENV["TEST_ENV_NUMBER"].to_i
end

origin = "#{protocol}://#{host}"
origin += ":#{port}" if [80, 443].exclude?(port)

WebAuthn.configure do |config|
  config.origin = origin
  config.rp_name = "MyFoodRepo"
  config.credential_options_timeout = 120_000
end
