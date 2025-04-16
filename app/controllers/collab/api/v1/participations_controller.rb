# frozen_string_literal: true

module Collab
  module Api
    module V1
      class ParticipationsController < BaseController
        before_action :set_cohort, only: %i[index create]
        before_action :set_participation, only: %i[show update]

        def index
          authorize(Participation)
          include_directive = permitted_include_directive(Participation, params[:include])
          participations = policy_scope(@cohort.participations).includes(include_directive)
          pagy, participations = pagy(participations)
          render jsonapi: participations, include: include_directive, meta: pagy_metadata(pagy), status: :ok
        end

        def show
          render jsonapi: @participation,
            include: permitted_include_directive(@participation, params[:include]),
            status: :ok
        end

        def create
          participation = @cohort.participations.new
          authorize(participation)
          if participation.save
            render jsonapi: participation,
              include: permitted_include_directive(participation, params[:include]),
              status: :ok
          else
            render jsonapi_errors: participation.errors, status: :unprocessable_entity
          end
        end

        def update
          if @participation.update(permitted_attributes(@participation)[:attributes])
            render jsonapi: @participation,
              include: permitted_include_directive(@participation, params[:include]),
              status: :ok
          else
            render jsonapi_errors: @participation.errors, status: :unprocessable_entity
          end
        end

        private def set_cohort
          @cohort = Cohort.find(params[:cohort_id])
        end

        private def set_participation
          @participation = Participation.find(params[:id])
          authorize(@participation)
        end
      end
    end
  end
end
