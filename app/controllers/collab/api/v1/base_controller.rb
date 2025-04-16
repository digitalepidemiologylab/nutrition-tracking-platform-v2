# frozen_string_literal: true

module Collab
  module Api
    module V1
      class BaseController < ApiController
        before_action :authenticate_collab_api_v1_collaborator!
        before_action :set_paper_trail_whodunnit

        def pundit_user
          current_collab_api_v1_collaborator
        end

        def policy_scope(scope)
          super([:collab, :api, :v1, scope])
        end

        def authorize(record, query = nil, policy_class: nil)
          super([:collab, :api, :v1, record], query, policy_class: policy_class)
        end

        def permitted_attributes(record, action = action_name)
          super([:collab, :api, :v1, record], action)
        end

        def permitted_include_directive(record, include_param, action = action_name)
          super([:collab, :api, :v1, record], include_param, action)
        end

        # For JSON API spec
        def pundit_params_for(_record)
          params.fetch(:data, {})
        end

        def user_for_paper_trail
          return "Unknown" unless current_collab_api_v1_collaborator

          "#{current_collab_api_v1_collaborator.class.name} #{current_collab_api_v1_collaborator.id}"
        end
      end
    end
  end
end
