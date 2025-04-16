# frozen_string_literal: true

class Barcode
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string

  validates :code, presence: true
  validate :validate_length
  validate :validate_checksum
  validate :validate_prefix

  # See GS1 spec, section 2.1.11.1
  def company_internal_numbering?
    code&.length == 8 && code.first.in?(%w[0 2])
  end

  def unrestricted_food?
    !code.nil? && Barcodes::GS1.prefix_datum(prefix: code[0..2])&.unrestricted_food?
  end

  # We support only ean8 and ean13, so the code length must be 8 or 13
  private def validate_length
    return if [8, 13].include?(code&.length)

    errors.add(:code, :invalid_length)
  end

  private def validate_checksum
    return if !code.nil? && code.last == Barcodes::GS1.check_digit(code_without_check_digit: code.chop)&.to_s

    errors.add(:code, :invalid_checksum)
  end

  private def validate_prefix
    return if !company_internal_numbering? && unrestricted_food?

    errors.add(:code, :invalid_prefix)
  end
end
