# frozen_string_literal: true

module Api
  module V2
    module Users
      class RegistrationsController < DeviseTokenAuth::RegistrationsController
        include HasLocale

        skip_before_action :verify_authenticity_token
        skip_before_action :validate_sign_up_params, only: :create
        skip_before_action :validate_account_update_params, only: :update
        before_action :verify_user_not_signed_in, only: :create

        def create
          participation = Participation.find_by(key: participation_params[:key])
          sign_form = if participation&.user.present?
            ::Users::Anonymous::SignInForm.new(participation: participation)
          else
            ::Users::Anonymous::SignUpForm.new(participation: participation)
          end
          sign_form.save!
          @resource = sign_form.user
          @token = sign_form.token
          update_auth_header
          render jsonapi: @resource, status: :ok
        rescue ActiveModel::ValidationError
          render jsonapi_errors: sign_form.errors, status: :unprocessable_entity
        end

        def update
          if @resource
            service = ::Users::UpdateService.new(user: @resource)
            if service.call(update_params)
              render jsonapi: service.user, status: :ok
            else
              render jsonapi_errors: service.errors, status: :unprocessable_entity
            end
          else
            render_update_error_user_not_found
          end
        rescue => e
          render jsonapi_errors: {title: e.class, detail: e.message}, status: :unprocessable_entity
        end

        def destroy
          ::Users::AnonymizeService.new(user: @resource).call(raise_exception: true)
          render_destroy_success
        rescue
          render_destroy_error
        end

        protected def render_destroy_success
          render jsonapi: nil, meta: {message: t("devise_token_auth.registrations.account_with_uid_destroyed", uid: @resource.id)}, status: :ok
        end

        protected def render_destroy_error
          error = {detail: t("devise_token_auth.registrations.account_to_destroy_not_found")}
          render jsonapi_errors: error, status: :not_found
        end

        private def verify_user_not_signed_in
          return unless set_user_by_token

          error = {detail: t("devise.failure.already_authenticated")}
          render jsonapi_errors: error, status: :unauthorized
        end

        private def participation_params
          params[:data].require(:attributes).permit(:key)
        end

        protected def render_update_error_user_not_found
          error = {detail: t("devise_token_auth.registrations.user_not_found")}
          render jsonapi_errors: error, status: :not_found
        end

        private def update_params
          params
            .require(:data)
            .permit(UserPolicy.new(current_api_v2_user, @resource).permitted_attributes)
        end
      end
    end
  end
end
