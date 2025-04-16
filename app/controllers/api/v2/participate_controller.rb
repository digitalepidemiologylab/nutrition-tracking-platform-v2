# frozen_string_literal: true

module Api
  module V2
    class ParticipateController < BaseController
      def create
        participation = Participation.find_by!(key: params.dig(:data, :attributes, :key))
        authorize(participation, policy_class: Api::V2::Participations::ParticipatePolicy)

        service = ::Participations::ParticipateService.new(participation: participation, user: current_api_v2_user)
        service.call

        render jsonapi: service.participation,
          include: permitted_include_directive(participation, params[:include]),
          status: :ok
      rescue ActiveModel::ValidationError
        render jsonapi_errors: service.errors, status: :unprocessable_entity
      end
    end
  end
end
