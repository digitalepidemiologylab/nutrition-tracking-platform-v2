# frozen_string_literal: true

require "view_component/test_helpers"

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, type: :component
end
