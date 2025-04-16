# frozen_string_literal: true

require "rails_helper"

describe(Seeds::FoodPortionsImportService) do
  let!(:food1) { create(:food, id_v1: 1) }
  let!(:food2) { create(:food, id_v1: 1003) }
  let!(:food3) { create(:food, id_v1: 1004, unit: create(:unit, :volume)) }
  let!(:food4) { create(:food, id_v1: 1005) }
  let!(:food5) { create(:food, id_v1: 1007) }
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_food_portions.zip")}
      }
    )
  }

  before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

  describe "#call" do
    it do
      expect { importer.call }.to not_change { food1.reload.portion_quantity }
        .and(change { food2.reload.portion_quantity }.from(nil).to(150))
        .and(not_change(food3, :unit_id))
        .and(change { food3.reload.portion_quantity }.from(nil).to(130))
        .and(change(food3, :unit_id).from("ml").to("g"))
        .and(not_change(food1, :food_list_id))
        .and(not_change(food2, :food_list_id))
        .and(not_change(food3, :food_list_id))
        .and(not_change(food4, :food_list_id))
        .and(not_change(food5, :food_list_id))
    end
  end
end
