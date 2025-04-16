# frozen_string_literal: true

module Api
  module V2
    module Users
      class PasswordsController < DeviseTokenAuth::PasswordsController
        include HasLocale

        skip_before_action :verify_authenticity_token

        # see https://github.com/lynndylanhurley/devise_token_auth/issues/130
        # about why we need the following line
        wrap_parameters false

        private def resource_params
          params[:data].require(:attributes).permit(:email, :reset_password_token)
        end

        private def validate_redirect_url_param
          @redirect_url = edit_participant_user_password_url(locale: params[:locale])
        end

        protected def render_create_success
          render jsonapi: nil,
            meta: {
              message: success_message("passwords", @email)
            },
            status: :accepted
        end

        protected def render_create_error(errors)
          render jsonapi_errors: errors, status: :bad_request
        end

        protected def render_not_found_error
          # because of Devise.paranoid
          render_create_success
        end
      end
    end
  end
end
