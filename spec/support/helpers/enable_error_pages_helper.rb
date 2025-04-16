# frozen_string_literal: true

RSpec.configure do |config|
  def enable_error_pages
    method = Rails.application.method(:env_config)
    allow(Rails.application).to receive(:env_config).with(no_args) do
      method.call.merge(
        "action_dispatch.show_exceptions" => :all,
        "action_dispatch.show_detailed_exceptions" => false
      )
    end
  end
end
