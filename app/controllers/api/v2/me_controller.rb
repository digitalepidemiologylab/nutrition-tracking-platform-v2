# frozen_string_literal: true

module Api
  module V2
    class MeController < BaseController
      def show
        authorize(current_api_v2_user, policy_class: Api::V2::MePolicy)
        render jsonapi: current_api_v2_user
      end
    end
  end
end
