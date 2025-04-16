# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = ENV.fetch("ENVIRONMENT")
  config.enabled_environments = %w[staging production]
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.0").to_f
end
