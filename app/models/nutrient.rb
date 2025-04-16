# frozen_string_literal: true

class Nutrient < ApplicationRecord
  extend Mobility
  belongs_to :unit, inverse_of: :nutrients
  has_many :food_nutrients, inverse_of: :nutrient, dependent: :restrict_with_error
  has_many :product_nutrients, inverse_of: :nutrient, dependent: :restrict_with_error

  has_paper_trail

  translates :name, dirty: true

  validates :id, codename: true
end
