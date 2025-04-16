# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.around(:each, :freeze_time) do |example|
    travel_to(Time.current.change(nsec: 0)) do
      example.run
    end
  end

  config.around(:each, :freeze_swagger_time) do |example|
    travel_to(Time.zone.parse("2021-12-12 12:12:12").change(nsec: 0)) do
      example.run
    end
  end
end
