# frozen_string_literal: true

module Api
  module V2
    class BaseController < ApiController
      before_action :authenticate_api_v2_user!
      before_action :set_paper_trail_whodunnit

      def pundit_user
        current_api_v2_user
      end

      def policy_scope(scope)
        super([:api, :v2, scope])
      end

      def authorize(record, query = nil, policy_class: nil)
        super([:api, :v2, record], query, policy_class: policy_class)
      end

      def permitted_attributes(record, action = action_name)
        super([:api, :v2, record], action)
      end

      def permitted_include_directive(record, include_param, action = action_name)
        super([:api, :v2, record], include_param, action)
      end

      # For JSON API spec
      def pundit_params_for(_record)
        params.fetch(:data, {})
      end

      def user_for_paper_trail
        return "Unknown" unless current_api_v2_user

        "#{current_api_v2_user.class.name} #{current_api_v2_user.id}"
      end
    end
  end
end
