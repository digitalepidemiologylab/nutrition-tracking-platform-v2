# frozen_string_literal: true

class BarcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_barcode) unless BarcodeValidator.valid?(value)
  end

  def self.valid?(barcode)
    Barcode.new(code: barcode).valid?
  end
end
