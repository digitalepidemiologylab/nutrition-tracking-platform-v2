# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define(:translate) do |attribute|
  match do |actual|
    actual.respond_to?(attribute) &
      actual.send("#{attribute}_en").present? &
      !actual.respond_to?("#{attribute}_unexpected")
  end
end
