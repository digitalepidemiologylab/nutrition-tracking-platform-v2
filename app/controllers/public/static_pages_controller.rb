# frozen_string_literal: true

module Public
  class StaticPagesController < BaseController
    skip_before_action :http_auth

    def terms
    end

    def privacy
    end
  end
end
