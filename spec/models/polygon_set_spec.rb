# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PolygonSet) do
  describe "Associations" do
    let(:polygon_set) { build(:polygon_set) }

    it do
      expect(polygon_set)
        .to belong_to(:dish_image).inverse_of(:polygon_sets)
      expect(polygon_set)
        .to belong_to(:annotation_item).inverse_of(:polygon_set)
      expect(polygon_set)
        .to belong_to(:segmentation_client).inverse_of(:polygon_sets).optional
    end
  end

  describe "Validations" do
    let(:polygon_set) { build(:polygon_set) }

    it { expect(polygon_set).to be_valid }

    describe "dish_image_id" do
      let(:polygon_set) { create(:polygon_set) }

      describe "uniqueness" do
        it do
          expect(polygon_set)
            .to validate_uniqueness_of(:dish_image_id)
            .scoped_to(:annotation_item_id)
            .case_insensitive
        end
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      describe "#set_dish_image" do
        let!(:dish) { create(:dish, :with_dish_image) }
        let!(:annotation) { create(:annotation, :with_annotation_item, dish: dish) }
        let!(:annotation_item) { annotation.annotation_items.sole }
        let!(:polygon_set) { build(:polygon_set, annotation_item: annotation_item, dish_image: nil) }

        it "sets dish_image on validation" do
          expect { polygon_set.validate }.to change(polygon_set, :dish_image).from(nil)
        end
      end
    end
  end

  describe "#polygons=(polygons)" do
    let(:polygons) {
      [[[0.474453, 0.27633], [0.631908, 0.277372]]]
    }

    describe "converts json string" do
      let(:polygon_set) { build(:polygon_set, polygons: polygons.to_json) }

      it do
        expect(polygon_set).to be_valid
      end
    end
  end
end
