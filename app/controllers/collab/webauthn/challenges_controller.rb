# frozen_string_literal: true

module Collab
  module Webauthn
    class ChallengesController < BaseController
      skip_before_action :verify_authenticity_token, :check_credentials

      def create
        authorize(WebauthnCredential, :create?)
        # Generate WebAuthn ID if the user does not have any yet
        current_collaborator.update(webauthn_id: WebAuthn.generate_user_id) unless current_collaborator.webauthn_id

        # Prepare the needed data for a challenge
        create_options = WebAuthn::Credential.options_for_create(
          user: {
            id: current_collaborator.webauthn_id,
            display_name: current_collaborator.name,
            name: current_collaborator.email # let's use email here
          },
          exclude: current_collaborator.webauthn_credentials.pluck(:external_id)
        )

        # Generate the challenge and save it into the session
        session[:webauthn_credential_register_challenge] = create_options.challenge

        render json: create_options
      end
    end
  end
end
