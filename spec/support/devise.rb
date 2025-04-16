# frozen_string_literal: true

require "devise"

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :requests
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Warden::Test::Helpers, type: :system
end
