# frozen_string_literal: true

class AnnotationItemForm
  attr_reader :annotation_item

  def initialize(annotation_item:)
    @annotation_item = annotation_item
  end

  def save(params = nil)
    annotation_item.set_from_portion = true
    annotation_item.attributes = params if params.present?
    if annotation_item.invalid?
      errors = annotation_item.errors.dup
      barcode = params[:barcode] if params.present?
      annotation_item.skip_validations = true
      annotation_item.save!
      annotation_item.errors.merge!(errors)
      if barcode.present? && annotation_item.errors[:barcode].present?
        annotation_item.errors.delete(:barcode)
        annotation_item.errors.add(:barcode, :invalid_barcode)
        annotation_item.product = Product.new(barcode: barcode)
      end
      false
    else
      annotation_item.save!
    end
  rescue => e
    annotation_item.errors.add(:base, e.message)
    false
  end
end
