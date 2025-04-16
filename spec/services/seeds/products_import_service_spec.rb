# frozen_string_literal: true

require "rails_helper"

describe(Seeds::ProductsImportService) do
  let(:importer) { described_class.new }
  let(:s3_client) {
    Aws::S3::Client.new(
      stub_responses: {
        get_object: lambda do |inst|
          key = inst.params.fetch(:key)
          if key == "myfoodrepo1_export/nutrients_latest.zip"
            {body: File.read("spec/support/data/myfoodrepo1_export/subset_nutrients.zip")}
          elsif key == "myfoodrepo1_export/products_latest.zip"
            {body: File.read("spec/support/data/#{key}")}
          end
        end
      }
    )
  }

  before do
    create_base_units
    create(:unit, id: :mg, factor: 0.001)
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    Seeds::NutrientsImportService.new.call
  end

  describe "#call" do
    describe "without limit param" do
      it do
        expect { importer.call }
          .to change(Product, :count).by(9)
          .and(change(Product::Translation, :count).by(16))
          .and(change(ProductNutrient, :count).by(38))
      end
    end

    describe "with limit param" do
      it do
        expect { importer.call(limit: 5) }
          .to change(Product, :count).by(5)
          .and(change(Product::Translation, :count).by(8))
          .and(change(ProductNutrient, :count).by(24))
      end
    end
  end
end
