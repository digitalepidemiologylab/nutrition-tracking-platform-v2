# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Annotations::FoodImagesGalleryQuery) do
  let(:cohort) { create(:cohort, :with_food_list) }
  let(:participation) { create(:participation, cohort: cohort) }
  let(:food_list) { cohort.food_lists.first }
  let(:user) { participation.user }
  let(:dish) { create(:dish, :with_dish_image, user: user) }
  let!(:food_1) { create(:food, food_list: food_list) }
  let!(:annotation_1_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_1)) }
  let!(:annotation_1_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_1)) }

  let!(:food_2) { create(:food, food_list: food_list) }
  let!(:annotation_2_1) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 1, food: food_2)) }
  let!(:annotation_2_2) { create(:annotation, dish: dish, participation: participation, annotation_items: build_list(:annotation_item, 2, food: food_2)) }

  let(:images_gallery_query_1) do
    described_class.new(food: food_1, initial_scope: Annotation.all)
  end

  let(:images_gallery_query_2) do
    described_class.new(food: food_2, initial_scope: Annotation.all)
  end

  describe "#query" do
    it do
      expect(images_gallery_query_1.query).to eq([annotation_1_2, annotation_1_1])
      expect(images_gallery_query_2.query).to eq([annotation_2_1, annotation_2_2])
    end
  end
end
