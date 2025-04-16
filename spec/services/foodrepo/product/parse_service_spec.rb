# frozen_string_literal: true

require "rails_helper"

describe(Foodrepo::Product::ParseService) do
  let(:data) do
    JSON.parse(file_fixture("webmock/foodrepo/products/coca_cola.json").read)["data"].first
  end
  let(:service) { described_class.new(data: data) }

  describe "#call", :freeze_time do
    context "when FoodRepo status is rescan" do
      it do # rubocop:disable RSpec/ExampleLength
        expect(service.call).to eq(
          data: {
            name_de: nil,
            name_en: "Coke",
            name_fr: "Coca-Cola",
            unit_id: "ml",
            portion_quantity: 330.0,
            fetched_at: Time.current,
            image_url: "https://d2v5oodgkvnw88.cloudfront.net/uploads_production/image/data/104479/xlarge_5449000009500.jpg?v=1516972200",
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
        )
      end
    end

    context "when FoodRepo status is complete" do
      before do
        data["status"] = "complete"
      end

      it do
        expect(service.call.fetch(:status)).to eq("complete")
      end
    end

    context "when FoodRepo status is draft" do
      before do
        data["status"] = "draft"
      end

      it do
        expect(service.call.fetch(:status)).to eq("incomplete")
      end
    end

    context "when FoodRepo status is submission" do
      before do
        data["status"] = "submission"
      end

      it do
        expect(service.call.fetch(:status)).to eq("incomplete")
      end
    end

    context "when FoodRepo status is name_only" do
      before do
        data["status"] = "name_only"
      end

      it do
        expect(service.call.fetch(:status)).to eq("incomplete")
      end
    end

    context "when FoodRepo status is archived" do
      before do
        data["status"] = "archived"
      end

      it do
        expect(service.call.fetch(:status)).to eq("incomplete")
      end
    end
  end
end
