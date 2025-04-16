# frozen_string_literal: true

module Collab
  class ProfilesController < BaseController
    before_action :set_collaborator
    before_action :set_breadcrumbs

    def show
      @collaborations = policy_scope(current_collaborator.collaborations).includes(:cohort)
      @webauthn_credentials = policy_scope(current_collaborator.webauthn_credentials)
      @tokens = current_collaborator.tokens
    end

    def edit
      @breadcrumbs << {text: t("helpers.edit")}
    end

    def update
      if @collaborator.update(permitted_attributes(@collaborator))
        notice = t("devise.registrations.updated")
        redirect_to collab_profile_path, notice: notice
      else
        @breadcrumbs << {text: t("helpers.edit")}
        render :edit, status: :unprocessable_entity
      end
    end

    private def set_collaborator
      @collaborator = current_collaborator
      authorize(@collaborator, policy_class: Collab::ProfilePolicy)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("collab.profiles.show.title"), url: collab_profile_path}]
    end
  end
end
