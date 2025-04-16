# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::PolygonSetPolicy) do
  let(:food_list) { create(:food_list) }
  let!(:admin) { create(:collaborator, :admin) }
  let!(:cohort_1) { create(:cohort, food_lists: [food_list]) }
  let!(:cohort_2) { create(:cohort, food_lists: [food_list]) }
  let!(:cohort_3) { create(:cohort, food_lists: [food_list]) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, cohort: cohort_1, collaborator: manager) }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, cohort: cohort_2, collaborator: annotator) }

  let!(:user_1) { create(:user) }
  let!(:user_1_dish) do
    create(
      :dish,
      user: user_1,
      annotations: build_list(
        :annotation, 1,
        participation: create(:participation, user: user_1, cohort: cohort_2),
        annotation_items: build_list(:annotation_item, 1, :with_polygon_set, food: build(:food, food_list: food_list))
      )
    )
  end
  let!(:user_1_annotation_item) { user_1_dish.annotations.sole.annotation_items.first }
  let!(:user_1_annotation_item_polygon_set) { user_1_annotation_item.polygon_set }

  let!(:user_2) { create(:user) }
  let!(:user_2_dish) do
    create(
      :dish,
      user: user_2,
      annotations: build_list(
        :annotation, 1,
        participation: create(:participation, user: user_2, cohort: cohort_1),
        annotation_items: build_list(:annotation_item, 1, :with_polygon_set, food: build(:food, food_list: food_list))
      )
    )
  end
  let!(:user_2_annotation_item) { user_2_dish.annotations.sole.annotation_items.first }
  let!(:user_2_annotation_item_polygon_set) { user_2_annotation_item.polygon_set }

  let!(:user_3) { create(:user) }
  let!(:user_3_dish) do
    create(
      :dish,
      user: user_3,
      annotations: build_list(
        :annotation, 1,
        participation: create(:participation, user: user_3, cohort: cohort_2),
        annotation_items: build_list(:annotation_item, 1, :with_polygon_set, food: build(:food, food_list: food_list))
      )
    )
  end
  let!(:user_3_annotation_item) { user_3_dish.annotations.sole.annotation_items.first }
  let!(:user_3_annotation_item_polygon_set) { user_3_annotation_item.polygon_set }

  let!(:user_4) { create(:user) }
  let!(:user_4_dish) do
    create(
      :dish,
      user: user_4,
      annotations: build_list(
        :annotation, 1,
        participation: create(:participation, user: user_4, cohort: cohort_3),
        annotation_items: build_list(:annotation_item, 1, :with_polygon_set, food: build(:food, food_list: food_list))
      )
    )
  end
  let!(:user_4_annotation_item) { user_4_dish.annotations.sole.annotation_items.first }
  let!(:user_4_annotation_item_polygon_set) { user_4_annotation_item.polygon_set }

  permissions :update?, :destroy? do
    context "when admin" do
      it do
        expect(described_class).to permit(admin, user_1_annotation_item_polygon_set)
        expect(described_class).to permit(admin, user_2_annotation_item_polygon_set)
        expect(described_class).to permit(admin, user_3_annotation_item_polygon_set)
        expect(described_class).to permit(admin, user_4_annotation_item_polygon_set)
      end
    end

    context "when manager" do
      it do
        expect(described_class).not_to permit(manager, user_1_annotation_item_polygon_set)
        expect(described_class).to permit(manager, user_2_annotation_item_polygon_set)
        expect(described_class).not_to permit(manager, user_3_annotation_item_polygon_set)
        expect(described_class).not_to permit(manager, user_4_annotation_item_polygon_set)
      end
    end

    context "when annotator" do
      it do
        expect(described_class).to permit(annotator, user_1_annotation_item_polygon_set)
        expect(described_class).not_to permit(annotator, user_2_annotation_item_polygon_set)
        expect(described_class).to permit(annotator, user_3_annotation_item_polygon_set)
        expect(described_class).not_to permit(annotator, user_4_annotation_item_polygon_set)
      end
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(annotator, user_1_annotation_item_polygon_set).permitted_attributes)
        .to contain_exactly(
          :polygons
        )
      expect(described_class.new(admin, user_1_annotation_item_polygon_set).permitted_attributes)
        .to contain_exactly(
          :polygons
        )
    end
  end
end
