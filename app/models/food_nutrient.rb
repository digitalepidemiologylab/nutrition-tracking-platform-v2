# frozen_string_literal: true

class FoodNutrient < ApplicationRecord
  has_paper_trail

  belongs_to :food, inverse_of: :food_nutrients
  belongs_to :nutrient, inverse_of: :food_nutrients

  validates :per_hundred, presence: true
  validate :unique_nutrient_per_food

  # Validating uniqueness of nutrient_id scoped to food_id doesn't work
  # on creation, hence the following method
  private def unique_nutrient_per_food
    return if food.nil? || nutrient.nil?
    return unless food.food_nutrients.count { |fn| fn.nutrient_id == nutrient_id } > 1

    errors.add(:nutrient_id, :taken)
  end
end
