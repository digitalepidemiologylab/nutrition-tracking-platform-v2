# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Segmentations::Aicrowd::ParseService) do
  let(:response_body) {
    file_fixture("webmock/aicrowd/webhook.json").read
  }
  let(:parsed_response_body) {
    json = JSON.parse(response_body).fetch("_json")
    json["response"].first["category_id"] = food_1.food_sets.first.id_v1 + 100_000
    json["response"].second["category_id"] = food_2.food_sets.first.id_v1 + 100_000
    json
  }

  let(:food_list) { create(:food_list) }
  let(:user) { create(:user) }
  let!(:dish) { create(:dish, :with_dish_image, user: user) }
  let!(:participation) { create(:participation, user: user, cohort: create(:cohort, food_lists: [food_list])) }

  let!(:annotation) {
    create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 3, :with_polygon_set, food: build(:food, food_list: food_list)))
  }
  let!(:segmentation_client) {
    create(:segmentation_client, name: "AIcrowd swiss-v3.0", ml_model: "swiss-v3.0")
  }
  let!(:food_1) { create(:food, :with_food_set, food_list: food_list) }
  let!(:food_2) { create(:food, :with_food_set, food_list: food_list) }

  let(:segmentation) do
    create(
      :segmentation,
      annotation: annotation,
      dish_image: dish.dish_image,
      segmentation_client: segmentation_client,
      response_body: parsed_response_body
    )
  end

  let(:service) { described_class.new(segmentation: segmentation) }

  before do
    segmentation.request!
    segmentation.receive!
    allow(Sentry).to receive(:capture_message)
  end

  describe "#call" do
    it do # rubocop:disable RSpec/ExampleLength
      expect { service.call }
        .to change(segmentation, :status).from("received").to("processed")
        .and(change(AnnotationItem, :count).by(-1)) # Destroy 3, create 2
        .and(change(PolygonSet, :count).by(-1)) # Destroy 3, create 2
      expect(Sentry).not_to have_received(:capture_message)
      polygon_set = PolygonSet.last
      expect(polygon_set.dish_image).to eq(dish.dish_image)
      expect(polygon_set.ml_dimensions).to eq([600, 400])
      expect(polygon_set.ml_confidence).to eq(0.9423536062240601)
      expect(polygon_set.polygons).to eq(
        [
          [
            [0.736667, 0.5475],
            [0.695, 0.56],
            [0.673333, 0.57],
            [0.645, 0.58],
            [0.626667, 0.5975],
            [0.581667, 0.645],
            [0.556667, 0.655],
            [0.541667, 0.6825],
            [0.511667, 0.7025],
            [0.495, 0.7175],
            [0.416667, 0.7275],
            [0.385, 0.75],
            [0.363333, 0.76],
            [0.338333, 0.78],
            [0.325, 0.8125],
            [0.311667, 0.8525],
            [0.305, 0.98],
            [0.311667, 1.08],
            [0.318333, 1.115],
            [0.325, 1.14],
            [0.333333, 1.165],
            [0.343333, 1.19],
            [0.351667, 1.2125],
            [0.366667, 1.255],
            [0.385, 1.305],
            [0.396667, 1.335],
            [0.441667, 1.395],
            [0.511667, 1.39],
            [0.545, 1.385],
            [0.593333, 1.395],
            [0.628333, 1.3975],
            [0.675, 1.3975],
            [0.71, 1.3875],
            [0.731667, 1.375],
            [0.758333, 1.33],
            [0.766667, 1.3],
            [0.77, 1.21],
            [0.755, 1.1525],
            [0.756667, 1.1125],
            [0.786667, 1.08],
            [0.818333, 1.0525],
            [0.848333, 1.03],
            [0.863333, 1.01],
            [0.876667, 0.965],
            [0.876667, 0.905],
            [0.87, 0.85],
            [0.863333, 0.8225],
            [0.856667, 0.7175],
            [0.85, 0.66],
            [0.843333, 0.635],
            [0.83, 0.5925],
            [0.81, 0.5625],
            [0.788333, 0.5525]
          ]
        ]
      )
      expect(AnnotationItem.first.food_set).to eq(food_2.food_sets.first)
      expect(AnnotationItem.first.position).to eq(1)
      expect(AnnotationItem.first.color_index).to eq(0)
      expect(AnnotationItem.first.original_food_set).to eq(food_2.food_sets.first)
      expect(AnnotationItem.first.food).to eq(food_2)
      expect(AnnotationItem.second.food_set).to eq(food_1.food_sets.first)
      expect(AnnotationItem.second.position).to eq(2)
      expect(AnnotationItem.second.color_index).to eq(1)
      expect(AnnotationItem.second.original_food_set).to eq(food_1.food_sets.first)
      expect(AnnotationItem.second.food).to eq(food_1)
    end

    context "when unknown category_id is returned" do
      let(:parsed_response_body) {
        json = JSON.parse(response_body).fetch("_json")
        json["response"].first["category_id"] = food_1.food_sets.first.id_v1 + 100_000
        json["response"].second["category_id"] = "unknown"
        json
      }

      it do
        expect { service.call }
          .to change(segmentation, :status).from("received").to("processed")
          .and(change(AnnotationItem, :count).by(-2)) # Destroy 3, create 1
          .and(change(PolygonSet, :count).by(-2)) # Destroy 3, create 1
        expect(Sentry).to have_received(:capture_message).with(
          "Unknown food set for category_id returned by Segmentations::Aicrowd::ParseService: `unknown`",
          level: :info
        )
        expect(AnnotationItem.first.food_set).to eq(food_1.food_sets.first)
        expect(AnnotationItem.first.original_food_set).to eq(food_1.food_sets.first)
        expect(AnnotationItem.first.food).to eq(food_1)
      end
    end

    context "when a category without food is returned" do
      let!(:food_set) { create(:food_set) }
      let(:parsed_response_body) {
        json = JSON.parse(response_body).fetch("_json")
        json["response"].first["category_id"] = food_1.food_sets.first.id_v1 + 100_000
        json["response"].second["category_id"] = food_set.id_v1 + 100_000
        json
      }

      it do
        expect { service.call }
          .to change(segmentation, :status).from("received").to("processed")
          .and(change(AnnotationItem, :count).by(-2)) # Destroy 3, create 1
          .and(change(PolygonSet, :count).by(-2)) # Destroy 3, create 1
        expect(Sentry).to have_received(:capture_message).with(
          "Unknown food for category_id returned by Segmentations::Aicrowd::ParseService: `#{food_set.id_v1}`",
          level: :info
        )
        expect(AnnotationItem.first.food_set).to eq(food_1.food_sets.first)
        expect(AnnotationItem.first.food).to eq(food_1)
      end
    end

    context "when polygon set is empty" do
      let(:parsed_response_body) do
        json = JSON.parse(response_body).fetch("_json")
        json["response"].first["category_id"] = food_1.food_sets.first.id_v1 + 100_000
        json["response"].second["category_id"] = food_2.food_sets.first.id_v1 + 100_000
        json["response"].first["polygons"] = []
        json
      end

      it do
        expect { service.call }
          .to change(segmentation, :status).from("received").to("processed")
          .and(change(AnnotationItem, :count).by(-1)) # Destroy 3, create 2
          .and(change(PolygonSet, :count).by(-2)) # Destroy 3, create 1
      end
    end
  end
end
