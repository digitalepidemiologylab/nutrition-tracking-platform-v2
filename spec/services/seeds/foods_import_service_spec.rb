# frozen_string_literal: true

require "rails_helper"

describe(Seeds::FoodsImportService) do
  let!(:country) { create(:country, :ch) }
  let!(:unit_mass) { create(:unit, :mass) }
  let!(:unit_volume) { create(:unit, :volume) }
  let!(:food_set_beer) { create(:food_set, cname: "beer") }
  let!(:food_set_beef) { create(:food_set, cname: "beef_n_s") }
  let!(:food_set_carrot) { create(:food_set, cname: "carrot") }
  let!(:food_set_cherry) { create(:food_set, cname: "cherry_stewed_drained_without_addition_of_sugar") }
  let!(:food_set_chocolate_1) do
    create(:food_set, cname: "chocolate_milk_chocolate_with_raisins_with_nuts_with_almonds")
  end
  let!(:food_set_cholcolate_2) { create(:food_set, cname: "chocolate_n_s") }
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_foods.zip")}
      }
    )
  }

  before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

  describe "#call" do
    it do
      expect { importer.call }.to change(Food, :count).by(10)
        .and(change(Food::Translation, :count).by(30))
    end
  end
end
