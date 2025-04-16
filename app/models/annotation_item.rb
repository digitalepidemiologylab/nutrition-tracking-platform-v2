# frozen_string_literal: true

class AnnotationItem < ApplicationRecord
  acts_as_list scope: :annotation
  has_paper_trail on: %i[destroy]

  attr_accessor :set_from_portion, :skip_food_presence_validation, :skip_validations

  belongs_to :annotation, inverse_of: :annotation_items
  belongs_to :food, inverse_of: :annotation_items, optional: true
  belongs_to :food_set, inverse_of: :annotation_items, optional: true
  belongs_to :original_food_set, class_name: "FoodSet", optional: true
  belongs_to :product, inverse_of: :annotation_items, optional: true
  belongs_to :present_unit, class_name: "Unit", optional: true
  belongs_to :consumed_unit, class_name: "Unit", optional: true
  has_one :polygon_set, inverse_of: :annotation_item, dependent: :destroy

  validates :present_unit_id,
    presence: {
      if: ->(annotation_item) {
        !skip_validations &&
          annotation_item.present_quantity.present?
      }
    }
  validates :consumed_unit_id,
    presence: {
      if: ->(annotation_item) {
        !skip_validations &&
          annotation_item.consumed_quantity.present?
      }
    }
  validates :barcode,
    barcode: {
      if: ->(annotation_item) {
        !skip_validations &&
          annotation_item.barcode.present? &&
          annotation_item.food.blank?
      },
      message: :invalid_barcode
    },
    presence: {
      if: ->(annotation_item) {
        !skip_validations &&
          annotation_item.food.blank?
      }
    }
  validate :kcal_in_range, unless: %i[disable_kcal_in_range_validation skip_validations]
  validate :food_must_be_from_same_food_lists_as_cohort

  before_validation :calculate_consumed_percent, :set_quantities, :set_consumed_kcal
  before_validation :set_color_index, on: :create

  delegate :polygons, :ml_confidence, to: :polygon_set, allow_nil: true
  delegate :barcode, to: :product, allow_nil: true

  def item=(item)
    raise(ArgumentError, "Item must be a Food or a Product") unless item.is_a?(Food) || item.is_a?(Product)

    if item.is_a?(Food)
      self.food = item
      self.product = nil
    end
    if item.is_a?(Product)
      self.product = item
      self.food = nil
    end
  end

  def barcode=(barcode)
    self.product = Product.find_or_create_by!(barcode: barcode)
  rescue ActiveRecord::RecordInvalid => e
    # Instantiate a new product just to keep the barcode in the UI.
    self.product = Product.new(barcode: barcode)
    errors.add(:barcode, e.message)
  end

  def item
    food.presence || product.presence
  end

  def calculated_consumed_quantity
    if consumed_quantity.present? && consumed_unit_id.present?
      consumed_quantity.to_f
    elsif consumed_quantity.present? && present_quantity.present? && present_unit_id.present?
      present_quantity.to_f * consumed_quantity.to_f / 100
    else
      present_quantity.to_f
    end
  end

  def in_unit?(unit_id)
    (consumed_quantity.present? && consumed_unit_id == unit_id) ||
      (
        (consumed_unit_id.blank? || consumed_quantity.blank?) &&
        present_unit_id == unit_id
      )
  end

  def polygons=(polygons)
    parsed_polygons = polygons.blank? ? [] : JSON.parse(polygons)
    if parsed_polygons.blank?
      polygon_set&.destroy
    elsif polygon_set.present?
      polygon_set.update!(polygons: parsed_polygons)
    else
      self.polygon_set = PolygonSet
        .create!(polygons: parsed_polygons, annotation_item: self, dish_image: annotation.dish.dish_image)
    end
  end

  private def set_color_index
    return if color_index.present? || annotation.blank?

    annotation_items = annotation.annotation_items
    self.color_index = annotation_items.index(self).to_i % 10
  end

  private def set_consumed_kcal
    self.consumed_kcal = AnnotationItems::CalculateKcalService.new(annotation_item: self).call
  end

  private def calculate_consumed_percent
    if consumed_unit_id != "%"
      self.consumed_percent = nil
    else
      self.consumed_percent = consumed_quantity
      self.consumed_unit = present_unit
      return unless consumed_percent && present_quantity

      self.consumed_quantity = present_quantity * consumed_percent / 100
    end
  end

  private def set_quantities
    return if !set_from_portion || !(will_save_change_to_food_id? || will_save_change_to_product_id?)

    if item&.portion_quantity
      self.present_quantity = item.portion_quantity
      self.consumed_quantity = item.portion_quantity
    end
    self.present_unit = item&.unit
    self.consumed_unit = item&.unit
  end

  private def kcal_in_range
    validates_with(KcalInRangeValidator)
  end

  private def food_must_be_from_same_food_lists_as_cohort
    cohort_food_list_ids = Array(annotation&.participation&.cohort&.food_lists&.pluck(:id)).compact
    return if food&.food_list_id.nil? || food.food_list_id.in?(cohort_food_list_ids)

    errors.add(:food, :invalid_food_list)
  end
end
