# frozen_string_literal: true

module Collab
  class BaseController < WebController
    include HasCollabAuthorization
    include HasAnnotationsRoute

    layout "collab"

    before_action :check_credentials, :set_paper_trail_whodunnit

    def user_for_paper_trail
      return "Unknown" unless current_collaborator

      "#{current_collaborator.class.name} #{current_collaborator.id}"
    end

    private def check_credentials
      return if !collaborator_signed_in? || current_collaborator.webauthn_credentials.any?

      redirect_to(
        new_collab_webauthn_credential_path,
        status: :see_other
      ) && return
    end
  end
end
