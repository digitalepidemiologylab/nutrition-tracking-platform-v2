# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Annotations::FoodSetImagesGalleryQuery) do
  let(:food_list) { create(:food_list) }
  let(:cohort) { create(:cohort, food_lists: [food_list]) }
  let(:participation) { create(:participation, cohort: cohort) }

  let(:dish) { create(:dish, :with_dish_image) }
  let!(:food_set_1) { create(:food_set) }
  let!(:food_1_1) { create(:food, food_sets: [food_set_1], food_list: food_list) }
  let!(:annotation_1_1_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_1_1)) }
  let!(:annotation_1_1_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_1_1)) }
  let!(:food_1_2) { create(:food, food_sets: [food_set_1], food_list: food_list) }
  let!(:annotation_1_2_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_1_2)) }
  let!(:annotation_1_2_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_1_2)) }

  let!(:food_set_2) { create(:food_set) }
  let!(:food_2_1) { create(:food, food_sets: [food_set_2], food_list: food_list) }
  let!(:annotation_2_1_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_2_1)) }
  let!(:annotation_2_1_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_2_1)) }
  let!(:food_2_2) { create(:food, food_sets: [food_set_2], food_list: food_list) }
  let!(:annotation_2_2_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_2_2)) }
  let!(:annotation_2_2_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_2_2)) }

  let(:images_gallery_query_1) do
    described_class.new(food_set: food_set_1, initial_scope: Annotation.all)
  end

  let(:images_gallery_query_2) do
    described_class.new(food_set: food_set_2, initial_scope: Annotation.all)
  end

  describe "#query" do
    it do
      query_result_1 = images_gallery_query_1.query
      expect(query_result_1[0..1]).to contain_exactly(annotation_1_1_2, annotation_1_2_1)
      expect(query_result_1[2..3]).to contain_exactly(annotation_1_1_1, annotation_1_2_2)

      query_result_2 = images_gallery_query_2.query
      expect(query_result_2[0..1]).to contain_exactly(annotation_2_1_2, annotation_2_2_1)
      expect(query_result_2[2..3]).to contain_exactly(annotation_2_1_1, annotation_2_2_2)
    end
  end
end
