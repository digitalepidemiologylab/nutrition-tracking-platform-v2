# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Nutrient) do
  describe "Association" do
    let(:nutrient) { build(:nutrient) }

    it do
      expect(nutrient).to belong_to(:unit).inverse_of(:nutrients)
      expect(nutrient).to have_many(:food_nutrients).inverse_of(:nutrient).dependent(:restrict_with_error)
      expect(nutrient).to have_many(:product_nutrients).inverse_of(:nutrient).dependent(:restrict_with_error)
    end
  end

  describe "Translation" do
    let(:nutrient) { build(:nutrient) }

    it { expect(nutrient).to translate(:name) }
  end

  describe "Validations" do
    describe "id" do
      let!(:nutrient) { build(:nutrient, id: "c_name") }

      it { expect(nutrient).to validate_codename_of(:id) }
    end
  end
end
