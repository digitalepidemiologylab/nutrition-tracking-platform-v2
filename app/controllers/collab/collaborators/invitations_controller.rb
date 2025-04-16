# frozen_string_literal: true

module Collab
  module Collaborators
    class InvitationsController < Devise::InvitationsController
      include HasHttpAuth
      include HasLocale
      include HasCollabAuthorization
      include HasAnnotationsRoute

      before_action :set_cohort, only: %i[new create]
      before_action :set_breadcrumbs, only: %i[new create]

      skip_after_action :verify_authorized, only: %i[edit update] # rubocop:disable LexicallyScopedActionFilter

      layout ->(controller) { %w[edit update].include?(controller.action_name) ? "public" : "collab" }

      def new
        @breadcrumbs << {text: t(".title")}

        self.resource = resource_class.new
        resource.collaborations.new(cohort: @cohort)
      end

      def create
        @breadcrumbs << {text: t("collab.collaborators.invitations.new.title")}

        email = params.dig(:collaborator, :email)
        @collaborator = Collaborator.find_by(email: email)

        if @collaborator.present?
          @collaborator.collaborations.new(
            cohort: @cohort,
            role: params.dig(:collaborator, :collaborations_attributes, "0", :role)
          )

          if @collaborator.save
            redirect_to collab_cohort_path(@cohort),
              notice: t(".collaborator_added_successfully", email: @collaborator.email)
          else
            render :new, status: :unprocessable_entity
          end
        else
          super
        end
      end

      def destroy
        # The destroy of the super class destroy the collaborator. But we don't want that as the collaborator
        # can be invited in others cohorts.
        raise ActionController::RoutingError.new("Not Found")
      end

      protected def after_invite_path_for(current_inviter, resource)
        collab_cohort_path(@cohort)
      end

      protected def after_accept_path_for(resource)
        collab_profile_path
      end

      private def set_cohort
        cohort_id = params[:cohort_id] || params.dig(:collaborator, :collaborations_attributes, "0", :cohort_id)
        @cohort = Cohort.find(cohort_id)
        authorize(@cohort, policy_class: Collab::Collaborators::InvitationPolicy)
      end

      private def set_breadcrumbs
        @breadcrumbs = [
          {text: t("layouts.collab.cohorts"), url: collab_cohorts_path},
          {text: @cohort.name, url: collab_cohort_path(@cohort)}
        ]
      end
    end
  end
end
