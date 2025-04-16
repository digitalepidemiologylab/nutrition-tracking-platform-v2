# frozen_string_literal: true

class ProductNutrient < ApplicationRecord
  belongs_to :product, inverse_of: :product_nutrients
  belongs_to :nutrient, inverse_of: :product_nutrients

  validates :per_hundred, presence: true
  validates :product_id, uniqueness: {scope: :nutrient_id}
end
