# frozen_string_literal: true

module Collab
  module Webauthn
    class AuthenticationsController < ::Public::BaseController
      def new
        collaborator = Collaborator.find_by(id: session.dig(:webauthn_authentication, "collaborator_id"))

        if collaborator
          render :new, layout: "devise"
        else
          redirect_to new_collaborator_session_path, error: t(".failure")
        end
      end

      def create
        # prepare needed data
        webauthn_credential = WebAuthn::Credential.from_get(params)
        collaborator = Collaborator.find(session[:webauthn_authentication]["collaborator_id"])
        credential = collaborator.webauthn_credentials.find_by(external_id: webauthn_credential.id)

        begin
          # verification
          webauthn_credential.verify(
            session[:webauthn_authentication]["challenge"],
            public_key: credential.public_key,
            sign_count: credential.sign_count
          )

          # update the sign count
          credential.update!(sign_count: webauthn_credential.sign_count)

          # signing the collaborator in manually
          sign_in(:collaborator, collaborator)

          # set the remember me - I hope this is working solution :)
          collaborator.remember_me! if session[:webauthn_authentication]["remember_me"]

          # set the redirect URL
          redirect = root_url

          # you can use flash messages here
          flash[:notice] = t("devise.sessions.signed_in")

          render json: {redirect: redirect}, status: :ok
        rescue WebAuthn::Error => e
          render json: "Verification failed: #{e.message}", status: :unprocessable_entity
        ensure
          session.delete(:webauthn_authentication)
        end
      end
    end
  end
end
