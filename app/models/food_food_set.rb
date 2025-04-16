# frozen_string_literal: true

class FoodFoodSet < ApplicationRecord
  has_paper_trail

  belongs_to :food, inverse_of: :food_food_sets
  belongs_to :food_set, inverse_of: :food_food_sets

  validates :food_id, uniqueness: {scope: :food_set_id}
end
