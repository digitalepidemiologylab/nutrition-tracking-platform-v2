# frozen_string_literal: true

module HasCollabAuthorization
  extend ActiveSupport::Concern

  include Pundit::Authorization

  included do
    after_action :verify_authorized
    after_action :verify_policy_scoped, only: :index # rubocop:disable LexicallyScopedActionFilter

    rescue_from Pundit::NotAuthorizedError, with: :collaborator_not_authorized
  end

  protected def pundit_user
    current_collaborator
  end

  protected def policy_scope(scope)
    super([:collab, scope])
  end

  protected def authorize(record, query = nil, policy_class: nil)
    super([:collab, record], query, policy_class: policy_class)
  end

  protected def permitted_attributes(record, action = action_name)
    super([:collab, record], action)
  end

  private def collaborator_not_authorized
    flash[:alert] = t("pundit.errors.messages.collaborator_not_authorized")
    allow_other_host = false
    destination_url = new_collaborator_session_path
    if current_collaborator.present?
      if request.referer
        destination_url = request.referer
        allow_other_host = true
      else
        destination_url = collab_profile_path
      end
    end
    redirect_to(destination_url, allow_other_host: allow_other_host)
  end
end
