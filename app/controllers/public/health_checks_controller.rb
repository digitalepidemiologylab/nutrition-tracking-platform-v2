# frozen_string_literal: true

module Public
  class HealthChecksController < Public::BaseController
    skip_around_action :set_locale
    skip_before_action :http_auth

    def show
      HealthCheckService.new.call
      head(:ok)
    rescue => e
      logger.error(e)
      head(:service_unavailable)
    end
  end
end
