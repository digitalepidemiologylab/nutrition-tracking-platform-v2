# frozen_string_literal: true

require "rails_helper"

describe(FoodFoodSet) do
  describe "Associations" do
    let(:food_food_set) { build(:food_food_set) }

    it do
      expect(food_food_set).to belong_to(:food).inverse_of(:food_food_sets)
      expect(food_food_set).to belong_to(:food_set).inverse_of(:food_food_sets)
    end
  end

  describe "Validations" do
    let(:food_food_set) { create(:food_food_set) }

    it do
      expect(food_food_set).to validate_uniqueness_of(:food_id).case_insensitive.scoped_to(:food_set_id)
    end
  end
end
