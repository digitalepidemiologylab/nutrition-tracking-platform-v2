# frozen_string_literal: true

class Barcodes::NormalizerService
  def initialize(barcode)
    @barcode = barcode
  end

  def call
    return nil if @barcode.nil?

    digits = @barcode.gsub(/[^0-9]+/, "")

    case digits.length
    when 8, 13
      digits
    when 12
      "0#{digits}" # Prepend 0 so that UPC-A becomes EAN-13
    when 14
      digits[1..] if digits.first == "0" # Remove leading 0 so a padded EAN-14 becomes EAN-13
    end
  end
end
