# frozen_string_literal: true

require "rails_helper"

describe(Seeds::FoodFoodSetsImportService) do
  let!(:food1) { create(:food, id_v1: 2) }
  let!(:food2) { create(:food, id_v1: 12) }
  let!(:food3) { create(:food, id_v1: 22) }
  let!(:food_set_beer) { create(:food_set, cname: "beer") }
  let!(:food_set_beef) { create(:food_set, cname: "beef_n_s") }
  let!(:food_set_carrot) { create(:food_set, cname: "carrot") }
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_food_food_sets.zip")}
      }
    )
  }

  before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

  describe "#call" do
    it { expect { importer.call }.to change(FoodFoodSet, :count).by(4) }
  end
end
