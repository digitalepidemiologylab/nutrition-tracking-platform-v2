# frozen_string_literal: true

require "jsonapi/rspec"

RSpec.configure do |config|
  config.include JSONAPI::RSpec
  config.include Rails.application.routes.url_helpers, type: :serializable

  # Support for documents with mixed string/symbol keys. Disabled by default.
  config.jsonapi_indifferent_hash = true
end
