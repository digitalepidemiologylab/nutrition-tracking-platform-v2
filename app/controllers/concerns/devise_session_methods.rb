# frozen_string_literal: true

module DeviseSessionMethods
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token

    # see https://github.com/lynndylanhurley/devise_token_auth/issues/130
    # about why we need the following line
    wrap_parameters false
  end

  protected def render_create_error_bad_credentials
    error = {detail: t("devise_token_auth.sessions.bad_credentials")}
    render(jsonapi_errors: error, status: :unauthorized)
  end

  def render_new_error
    error = {detail: t("devise_token_auth.sessions.not_supported")}
    render(jsonapi_errors: error, status: :method_not_allowed)
  end

  protected def render_create_success
    render jsonapi: @resource, status: :ok
  end

  protected def render_destroy_success
    render(json: {}, status: :ok)
  end

  protected def render_destroy_error
    error = {detail: t("devise_token_auth.sessions.user_not_found")}
    render(jsonapi_errors: error, status: :not_found)
  end

  private def resource_params
    params[:data].require(:attributes).permit(*params_for_resource(:sign_in))
  end
end
