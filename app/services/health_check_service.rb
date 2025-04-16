# frozen_string_literal: true

class HealthCheckService
  def call
    postgres_health_check
    redis_health_check
  end

  private def postgres_health_check
    ActiveRecord::Base.connection.execute("SELECT 1")
  end

  private def redis_health_check
    Redis.new(url: ENV["REDIS_SIDEKIQ_URL"]).ping
    Redis.new(url: ENV["REDIS_CABLE_URL"]).ping
  end
end
