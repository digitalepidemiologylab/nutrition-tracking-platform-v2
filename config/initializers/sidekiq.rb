# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

redis_params = {
  url: ENV.fetch("REDIS_SIDEKIQ_URL", ENV["REDIS_URL"]),
  ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
}

Sidekiq.configure_server do |config|
  config.redis = {**redis_params, size: 10}
end

Sidekiq.configure_client do |config|
  config.redis = {**redis_params, size: 1}
end
