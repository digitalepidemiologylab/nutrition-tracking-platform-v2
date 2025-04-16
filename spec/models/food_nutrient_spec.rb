# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FoodNutrient) do
  describe "Associations" do
    let(:food_nutrient) { build(:food_nutrient) }

    it do
      expect(food_nutrient).to belong_to(:food).inverse_of(:food_nutrients)
      expect(food_nutrient).to belong_to(:nutrient).inverse_of(:food_nutrients)
    end
  end

  describe "Validations" do
    let(:food_nutrient) { build(:food_nutrient) }

    describe "per_hundred" do
      it { expect(food_nutrient).to validate_presence_of(:per_hundred) }
    end

    describe "unique_nutrient_per_food" do
      let!(:food) { create(:food) }
      let!(:nutrient) { create(:nutrient) }
      let!(:food_nutrient_1) { create(:food_nutrient, food: food, nutrient: nutrient) }

      context "when food_nutrient is unique" do
        it do
          expect(food_nutrient_1).to be_valid
        end
      end

      context "when food_nutrient is not unique" do
        let(:food_nutrient_2) { build(:food_nutrient, food: food, nutrient: nutrient) }

        it do
          expect(food_nutrient_2).not_to be_valid
          expect(food_nutrient_2.errors.messages[:nutrient_id]).to include("has already been taken")
        end
      end
    end
  end
end
