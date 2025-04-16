# frozen_string_literal: true

module Public
  class ErrorsController < Public::BaseController
    layout "application"

    skip_around_action :set_locale

    def show
      I18n.locale = locale_from_request_or_default
      @status_code = params[:status_code]
      render status: @status_code
    end
  end
end
