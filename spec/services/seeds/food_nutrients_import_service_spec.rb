# frozen_string_literal: true

require "rails_helper"

describe(Seeds::FoodNutrientsImportService) do
  let!(:food1) { create(:food, id_v1: 2) }
  let!(:food2) { create(:food, id_v1: 12) }
  let!(:nutrient_energy_kj) { create(:nutrient, id: "energy_kj") }
  let!(:nutrient_energy_kcal) { create(:nutrient, id: "energy_kcal") }
  let!(:nutrient_protein) { create(:nutrient, id: "protein") }
  let!(:nutrient_alcohol) { create(:nutrient, id: "alcohol") }
  let!(:nutrient_water) { create(:nutrient, id: "water") }
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_food_nutrients.zip")}
      }
    )
  }

  before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

  describe "#call" do
    it { expect { importer.call }.to change(FoodNutrient, :count).by(10) }
  end
end
