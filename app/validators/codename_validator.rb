# frozen_string_literal: true

class CodenameValidator < ActiveModel::EachValidator
  RESERVED = %i[all none].freeze
  REGEX = /\A[a-z0-9_&]*\z/

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_codename) unless CodenameValidator.valid?(value)
  end

  def self.valid?(codename)
    case codename
    when String, Symbol
      str = codename.to_s
      str.match?(REGEX) && !str.downcase.to_sym.in?(RESERVED)
    else
      false
    end
  end
end
