# frozen_string_literal: true

module Collab
  class CollaboratorsController < BaseController
    before_action :set_breadcrumbs

    def index
      authorize(Collaborator)
      @collaborators = policy_scope(Collaborator).order(:name)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.collaborators"), url: collab_collaborators_path}]
    end
  end
end
