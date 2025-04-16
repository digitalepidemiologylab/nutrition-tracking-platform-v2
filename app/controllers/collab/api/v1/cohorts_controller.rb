# frozen_string_literal: true

module Collab
  module Api
    module V1
      class CohortsController < BaseController
        before_action :set_cohort, only: %i[show]

        def show
          render jsonapi: @cohort,
            include: permitted_include_directive(@cohort, params[:include]),
            status: :ok
        end

        private def set_cohort
          @cohort = Cohort.find(params[:id])
          authorize(@cohort)
        end
      end
    end
  end
end
