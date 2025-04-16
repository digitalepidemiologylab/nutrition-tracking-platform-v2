# frozen_string_literal: true

class Annotation < ApplicationRecord
  include AASM

  aasm column: :status, no_direct_assignment: true, whiny_persistence: true do
    state :initial, initial: true
    state :awaiting_segmentation_service
    state :annotatable
    state :info_asked
    state :annotated

    after_all_transitions :touch_intakes

    event :send_to_segmentation_service do
      transitions from: :initial, to: :awaiting_segmentation_service
    end

    event :open_annotation do
      transitions from: %i[initial awaiting_segmentation_service info_asked annotated], to: :annotatable
    end

    event :confirm do
      transitions from: :annotatable, to: :annotated

      success do
        reset_annotation_items_food_set
      end
    end

    event :ask_info do
      transitions from: :annotatable, to: :info_asked
    end
  end

  belongs_to :dish, inverse_of: :annotations
  belongs_to :participation, inverse_of: :annotations
  has_one :segmentation, inverse_of: :annotation, dependent: :destroy
  has_many :intakes, inverse_of: :annotation, dependent: :destroy
  has_many :annotation_items, inverse_of: :annotation, dependent: :destroy
  has_many :products, through: :annotation_items
  has_many :comments, inverse_of: :annotation, dependent: :destroy
  has_one :last_intake, -> { order(consumed_at: :desc) }, class_name: "Intake" # rubocop:disable Rails/InverseOf

  accepts_nested_attributes_for :annotation_items

  validates :intakes, presence: true
  validates_associated :annotation_items

  after_create_commit :segment_or_open_annotation
  after_destroy_commit :destroy_dish_if_no_annotations

  delegate :has_image?, to: :dish
  delegate :cohort, to: :participation
  delegate :food_lists, to: :cohort

  def image
    image = dish.dish_image || product_image
    return image if image.is_a?(String)

    image&.data
  end

  def total_consumed(unit_id = "g")
    annotation_items_in_unit(unit_id)
      .sum { |annotation_item| annotation_item.calculated_consumed_quantity }
  end

  def total_kcal_consumed
    annotation_items.pluck(:consumed_kcal).compact.sum.round(2)
  end

  private def product_image
    @product_image ||= begin
      return unless annotation_items.size == 1

      product = products.where.not(image_url: nil).first
      return product.image_url if product

      product = products.joins(:product_images).first
      return unless product

      product.product_images.first
    end
  end

  private def annotation_items_in_unit(unit_id)
    # We do this in Ruby to allow calculations on annotation_items that are not persisted yet.
    annotation_items.select do |annotation_item|
      !annotation_item.destroyed? && annotation_item.in_unit?(unit_id.to_s)
    end
  end

  private def segment_or_open_annotation
    if has_image?
      Annotations::CreateSegmentationJob.perform_later(annotation: self)
    else
      open_annotation!
    end
  end

  private def touch_intakes
    intakes.touch_all
  end

  private def reset_annotation_items_food_set
    annotation_items.update_all(food_set_id: nil)
  end

  private def destroy_dish_if_no_annotations
    dish.destroy unless dish.annotations.exists?
  end
end
