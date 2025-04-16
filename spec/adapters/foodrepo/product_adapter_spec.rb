# frozen_string_literal: true

require "rails_helper"

describe Foodrepo::ProductAdapter do
  # Coke barcode
  let(:barcode) { "5449000009500" }
  let(:product) { create(:product, :with_product_images, barcode: barcode) }
  let(:adapter) { described_class.new(product: product) }

  describe "#fetch_all(barcodes:)", :freeze_time do
    let(:response) { adapter.fetch_all(barcodes: barcodes) }

    context "when API key is wrong" do
      let(:barcodes) { %w[7610848493136] }
      let!(:old_foodrepo_key) { ENV["FOODREPO_KEY"] }

      # The old key will be used by all requests since it is cached when the adapter class is loaded.
      # But changing the ENV var will change which key is considered correct in the webmock request handling block
      before { ENV["FOODREPO_KEY"] = "different_key" }

      after { ENV["FOODREPO_KEY"] = old_foodrepo_key }

      it { expect { response }.to raise_error(described_class::ApiCallError) }
    end

    context "when barcodes is a array" do
      let(:barcodes) { %w[7610848493136 7611654884033 7610800972105 7610807015843 7611654457411 7610807017977 7610800990178 3046920029759 7611654666875 7610632050217] }

      it do # rubocop:disable RSpec/ExampleLength
        expect(response).to be_a(Array)
        expect(response.size).to eq(10)
        expect(response.last).to eq({
          data: {
            fetched_at: Time.current,
            image_url: "https://dflrtkwiq6x6s.cloudfront.net/uploads_production/image/data/4006/xlarge_myImage.jpg?v=1468837025",
            name_de: "Naturaplan Feigen",
            name_en: "Naturaplan Figs",
            name_fr: "Naturaplan Figues",
            portion_quantity: 40.0,
            product_nutrients_attributes: [
              {nutrient_id: "fat", per_hundred: 0.5},
              {nutrient_id: "carbohydrates", per_hundred: 58.0},
              {nutrient_id: "sugar", per_hundred: 47.0},
              {nutrient_id: "fiber", per_hundred: 10.0},
              {nutrient_id: "protein", per_hundred: 3.0}
            ],
            source: "FoodRepo\n#{ENV.fetch("FOODREPO_API_BASE_URI")}\n7610632050217",
            unit_id: "g"
          },
          barcode: "7610632050217",
          foodrepo_id: 991,
          status: "complete"
        })
      end
    end

    context "when barcode isn't an Array" do
      let(:barcodes) { {} }

      it do
        expect(response).to be_empty
      end
    end
  end

  describe "#fetch(barcode:)", :freeze_time do
    let(:response) { adapter.fetch }

    context "when barcode exists" do
      it do # rubocop:disable RSpec/ExampleLength
        expect(response).to eq({
          data: {
            fetched_at: Time.current,
            image_url: "https://d2v5oodgkvnw88.cloudfront.net/uploads_production/image/data/104479/xlarge_5449000009500.jpg?v=1516972200",
            name_de: nil,
            name_en: "Coke",
            name_fr: "Coca-Cola",
            unit_id: "ml",
            portion_quantity: 330.0,
            source: "FoodRepo\n#{ENV.fetch("FOODREPO_API_BASE_URI")}\n5449000009500",
            product_nutrients_attributes: [
              {nutrient_id: "energy_kj", per_hundred: 182.0},
              {nutrient_id: "energy_kcal", per_hundred: 43.0},
              {nutrient_id: "fat", per_hundred: 0.0},
              {nutrient_id: "fatty_acids_saturated", per_hundred: 0.0},
              {nutrient_id: "carbohydrates", per_hundred: 10.7},
              {nutrient_id: "sugar", per_hundred: 10.7},
              {nutrient_id: "fiber", per_hundred: 0.0},
              {nutrient_id: "protein", per_hundred: 0.0},
              {nutrient_id: "salt", per_hundred: 0.0}
            ]
          },
          barcode: "5449000009500",
          foodrepo_id: 22784,
          status: "incomplete"
        })
      end
    end

    context "when barcode doesnt exists" do
      before { product.barcode = "unknown" }

      it do
        expect(response).to eq({})
      end
    end
  end

  describe "#create" do
    let(:response) { adapter.create }

    context "when successful" do
      it do
        expect(response.code).to eq(201) # rubocop:disable RSpec/Rails/HaveHttpStatus
        expect(response.to_h).to eq("status" => "created", "meta" => {"api_version" => "3.03", "generated_in" => 461})
      end
    end
  end

  describe "#update(foodrepo_id:, product:)" do
    # Coke barcode foodrepo id
    let(:foodrepo_id) { 22784 }
    let(:product) { create(:product, :with_product_images) }
    let(:barcode) { product.barcode }

    let(:response) { adapter.update(foodrepo_id: foodrepo_id) }

    context "when successful" do
      it do
        expect(response.code).to eq(204) # rubocop:disable RSpec/Rails/HaveHttpStatus
        expect(response.to_h).to be_empty
      end
    end
  end

  describe "#updated_after(datetime:)", :freeze_time do
    context "when successful" do
      let(:response) { adapter.updated_after(datetime: 1.month.ago) }

      it do
        expect(response.size).to eq(7)
        expect(response.first.keys).to contain_exactly(:barcode, :data, :foodrepo_id, :status)
      end
    end

    context "when call to service fails" do
      let(:payload) do
        Struct.new(:code, :body).new(500, "Internal Server Error")
      end

      before do
        allow(described_class).to receive(:post).and_return(payload)
      end

      it { expect { adapter.updated_after(datetime: 1.month.ago) }.to raise_error(Foodrepo::ProductAdapter::ApiCallError) }
    end
  end
end
