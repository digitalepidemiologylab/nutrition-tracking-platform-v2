# frozen_string_literal: true

module Api
  module V2
    class ParticipationsController < BaseController
      def index
        authorize(Participation)
        include_directive = permitted_include_directive(Participation, params[:include])
        participations = policy_scope(Participation).includes(include_directive)
        pagy, participations = pagy(participations)
        render jsonapi: participations, include: include_directive, meta: pagy_metadata(pagy), status: :ok
      end
    end
  end
end
