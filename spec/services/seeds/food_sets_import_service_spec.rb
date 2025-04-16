# frozen_string_literal: true

require "rails_helper"

describe(Seeds::FoodSetsImportService) do
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_food_sets.zip")}
      }
    )
  }

  before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

  describe "#call" do
    it do
      expect { importer.call }.to change(FoodSet, :count).by(10)
        .and(change(FoodSet::Translation, :count).by(30))
    end
  end
end
