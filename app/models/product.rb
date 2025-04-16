# frozen_string_literal: true

class Product < ApplicationRecord
  include AASM
  include SearchableByName
  extend Mobility

  has_paper_trail on: %i[destroy]

  aasm column: :status, no_direct_assignment: true, whiny_persistence: true do
    state :initial, initial: true
    state :complete
    state :incomplete

    event :mark_incomplete do
      transitions from: %i[initial complete], to: :incomplete
    end

    event :mark_complete do
      transitions from: %i[initial incomplete], to: :complete
    end
  end

  belongs_to :unit, inverse_of: :products
  has_many :annotation_items, inverse_of: :product, dependent: :restrict_with_error
  has_many :product_images, inverse_of: :product, dependent: :destroy
  has_many :product_nutrients, inverse_of: :product, dependent: :destroy

  accepts_nested_attributes_for :product_nutrients
  accepts_nested_attributes_for :product_images

  translates :name, dirty: true

  validates :barcode, presence: true, barcode: true

  before_validation :normalize_barcode
  after_create_commit :fetch_data

  private def normalize_barcode
    self.barcode = Barcodes::NormalizerService.new(barcode).call
  end

  private def fetch_data
    Products::FetchDataJob.perform_later(product: self)
  end
end
