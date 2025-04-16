# frozen_string_literal: true

class ApiController < ApplicationController
  class BadIncludeParam < StandardError; end

  include HasLocale
  include Pundit::Authorization
  include DeviseTokenAuth::Concerns::SetUserByToken

  protect_from_forgery with: :null_session

  before_action :check_app_version
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index # rubocop:disable LexicallyScopedActionFilter

  rescue_from Exception do |e|
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
    render jsonapi_errors: {title: e.class, detail: t("api_controller.internal_server_error")},
      status: :internal_server_error
  end

  rescue_from BadIncludeParam, BaseQuery::BadFilterParam, ActionController::ParameterMissing do |e|
    render jsonapi_errors: {title: e.class, detail: e.message}, status: :unprocessable_entity
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    render jsonapi_errors: {title: e.class, detail: e.message}, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render jsonapi_errors: {title: e.class, detail: t("api_controller.record_not_found", model: e.model)},
      status: :not_found
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    render jsonapi_errors: {title: e.class, detail: t("api_controller.record_not_unique"), code: :record_not_unique},
      status: :conflict
  end

  rescue_from Pagy::OverflowError do |e|
    render jsonapi_errors: {title: e.class, detail: e.message}, status: :not_found
  end

  def permitted_include_directive(record, include_param, action = action_name)
    return nil if include_param.nil?

    policy = policy(record)
    method_name = if policy.respond_to?("permitted_includes_for_#{action}")
      "permitted_includes_for_#{action}"
    else
      "permitted_includes"
    end

    includes = include_param.split(",")
    permitted_includes = includes.intersection(policy.public_send(method_name))

    if includes.length != permitted_includes.length
      raise BadIncludeParam,
        t("api_controller.bad_include_param", bad_includes: (includes - permitted_includes).join(", "))
    end

    JSONAPI::IncludeDirective.new(permitted_includes.join(",")).to_hash
  end

  private def check_app_version
    return if UserAgents::SupportService.new(user_agent: request.user_agent).call

    render(
      jsonapi_errors: {
        title: "UpgradeRequired",
        detail: t("api_controller.upgrade_required"),
        code: :mobile_app_upgrade_required
      },
      status: :upgrade_required
    )
  end
end
