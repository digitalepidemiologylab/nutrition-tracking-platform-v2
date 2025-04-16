# frozen_string_literal: true

module Collab
  module Webauthn
    class CredentialsController < BaseController
      skip_before_action :check_credentials

      def new
        @credential = WebauthnCredential.new
        authorize(@credential)
        render layout: "devise"
      end

      def create
        # Create WebAuthn Credentials from the request params
        webauthn_credential = WebAuthn::Credential.from_create(params[:credential])
        authorize(WebauthnCredential)

        begin
          # Validate the challenge
          webauthn_credential.verify(session[:webauthn_credential_register_challenge])

          # The validation would raise WebAuthn::Error so if we are here, the credentials are valid, and we can save it
          @credential = current_collaborator.webauthn_credentials.new(
            external_id: webauthn_credential.id,
            public_key: webauthn_credential.public_key,
            nickname: params[:nickname],
            sign_count: webauthn_credential.sign_count
          )

          if @credential.save
            @url = root_path
            flash[:notice] = t(".success")
          else
            render turbo_stream: turbo_stream.update("webauthn_credential_error", "<p class=\"text-red-400 mt-2\">Couldn't add your Security Key</p>")
          end
        rescue WebAuthn::Error => e
          render turbo_stream: turbo_stream.update("webauthn_credential_error", "<p class=\"text-red-400 mt-2\">Verification failed: #{e.message}</p>")
        ensure
          session.delete(:webauthn_credential_register_challenge)
        end
      end

      def destroy
        @credential = current_collaborator.webauthn_credentials.find(params[:id])
        authorize(@credential)
        if @credential.destroy
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".failure")
        end
      end
    end
  end
end
