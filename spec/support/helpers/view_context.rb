# frozen_string_literal: true

class ViewContextDelegator
  RouteHelpers = Module.new { delegate_missing_to "Rails.application.routes.url_helpers" }
  HELPERS = ApplicationController.helpers.extend(RouteHelpers)
  delegate_missing_to(:HELPERS)
end

RSpec.configure do |config|
  def view_context_stub
    @view_context_stub ||= ViewContextDelegator.new
  end
end
