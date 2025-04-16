# frozen_string_literal: true

module Collab
  module Participations
    class CreateFormsController < BaseController
      # This is required to set a custom url for pagy pagination.
      # Here pagination url needs to be collab_cohort_participations_path(@cohort).
      require "pagy/extras/standalone"

      before_action :set_cohort

      def create
        @participations_create_form = ::Participations::CreateForm.new(cohort: @cohort)
        authorize(@participations_create_form)

        if @participations_create_form.save(permitted_attributes(@participations_create_form))
          respond_to do |format|
            format.turbo_stream do
              flash.now[:notice] = t(".success")
              set_pagy_participations
            end
            format.html do
              flash[:notice] = t(".success")
              redirect_to collab_cohort_participations_path(@cohort)
            end
          end
        else
          respond_to do |format|
            set_pagy_participations
            format.turbo_stream
            format.html {
              render "collab/participations/index", status: :unprocessable_entity
            }
          end
        end
      end

      private def set_cohort
        @cohort = Cohort.find(params[:cohort_id])
      end

      private def set_pagy_participations
        relation = policy_scope(@cohort.participations).order(created_at: :desc)
        @pagy_participations, @participations = pagy(relation, url: collab_cohort_participations_path(@cohort))
      end
    end
  end
end
