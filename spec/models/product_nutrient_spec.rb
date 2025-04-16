# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ProductNutrient) do
  describe "Associations" do
    let(:product_nutrient) { build(:product_nutrient) }

    it do
      expect(product_nutrient).to belong_to(:product).inverse_of(:product_nutrients)
      expect(product_nutrient).to belong_to(:nutrient).inverse_of(:product_nutrients)
    end
  end

  describe "Validations" do
    let(:product_nutrient) { build(:product_nutrient) }

    describe "per_hundred" do
      it { expect(product_nutrient).to validate_presence_of(:per_hundred) }
    end

    describe "product_id" do
      let(:product_nutrient) { build(:product_nutrient, product: create(:product), nutrient: create(:nutrient)) }

      it do
        expect(product_nutrient).to validate_uniqueness_of(:product_id).case_insensitive.scoped_to(:nutrient_id)
      end
    end
  end
end
