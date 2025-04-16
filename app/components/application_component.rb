# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  class InvalidArgumentError < StandardError; end

  def validate_inclusion_of(attr, value:, accepted_values:)
    return if value.nil? || value.in?(accepted_values)

    raise(InvalidArgumentError, "#{attr.capitalize} argument must be in #{accepted_values.join(", ")}")
  end
end
