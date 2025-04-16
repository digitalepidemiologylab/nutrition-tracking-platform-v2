# frozen_string_literal: true

module Collab
  module Collaborators
    class SessionsController < Devise::SessionsController
      include HasLocale

      def create
        self.resource = warden.authenticate!(auth_options)
        session.delete(:webauthn_authentication)
        if resource.webauthn_credentials.any?
          # preserve the stored location
          stored_location = stored_location_for(resource)

          # log out the collaborator (this will also clear stored location)
          warden.logout

          # restore the stored location
          store_location_for(resource, stored_location)

          # set session data
          session[:webauthn_authentication] = {collaborator_id: resource.id, remember_me: params[:collaborator][:remember_me] == "1"}

          # redirect to the webauthn page
          redirect_to(new_collab_webauthn_authentication_url)
        else
          # continue without webauthn
          set_flash_message!(:notice, :signed_in)
          sign_in(resource_name, resource)
          yield resource if block_given?
          respond_with resource, location: after_sign_in_path_for(resource)
        end
      end

      def destroy
        current_collaborator.reset_session_token
        session.delete(:webauthn_authentication)
        super
      end
    end
  end
end
