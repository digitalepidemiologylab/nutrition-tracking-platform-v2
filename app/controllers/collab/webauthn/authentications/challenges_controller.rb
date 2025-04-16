# frozen_string_literal: true

module Collab
  module Webauthn
    module Authentications
      class ChallengesController < BaseController
        skip_before_action :verify_authenticity_token, :check_credentials

        def create
          skip_authorization
          collaborator = Collaborator.find_by(id: session[:webauthn_authentication]["collaborator_id"])

          if collaborator
            # prepare WebAuthn options
            get_options = WebAuthn::Credential.options_for_get(allow: collaborator.webauthn_credentials.pluck(:external_id))

            # save the challenge
            session[:webauthn_authentication]["challenge"] = get_options.challenge

            respond_to do |format|
              format.json { render json: get_options }
            end
          else
            respond_to do |format|
              format.json { render json: {message: t(".failure")}, status: :unprocessable_entity }
            end
          end
        end
      end
    end
  end
end
