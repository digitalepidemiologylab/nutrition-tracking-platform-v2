# frozen_string_literal: true

class TimezoneValidator < ActiveModel::EachValidator
  VALID_TIMEZONES = TZInfo::Timezone.all_identifiers.freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_timezone) unless TimezoneValidator.valid?(value)
  end

  def self.valid?(timezone)
    VALID_TIMEZONES.include?(timezone)
  end
end
