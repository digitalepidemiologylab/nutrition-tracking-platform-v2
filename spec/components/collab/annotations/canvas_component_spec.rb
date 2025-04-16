# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Annotations::CanvasComponent) do
  let!(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:food_list) { cohort.food_lists.first }

  let!(:annotation) { create(:annotation, participation: participation, annotation_items: build_list(:annotation_item, 2, :with_polygon_set, food: build(:food, food_list: food_list))) }
  let(:annotation_item_1) { annotation.annotation_items.first }
  let(:annotation_item_2) { annotation.annotation_items.second }

  context "when annotation_item is nil" do
    let(:component) do
      described_class.new(
        annotation: annotation, annotation_items: annotation.annotation_items
      )
    end

    it do
      render_inline(component)

      expect(page).to have_css("canvas", id: "canvas_annotation_#{annotation.id}")
      expect(page).not_to have_css("canvas[data-color-index]")
      expect(page).to have_css("canvas[data-canvas-polygons-value]")
      expect(page).not_to have_css("canvas[data-canvas-annotation-item-id-value]")
    end
  end

  context "when annotation_item is not nil" do
    let(:component) do
      described_class.new(
        annotation: annotation,
        annotation_item: annotation_item_1,
        annotation_items: annotation.annotation_items
      )
    end

    it do
      render_inline(component)

      expect(page).to have_css("canvas", id: "canvas_annotation_#{annotation.id}")
      expect(page).to have_css("canvas[data-color-index]")
      expect(page).to have_css("canvas[data-canvas-polygons-value]")
      expect(page).to have_css("canvas[data-canvas-annotation-item-id-value]")
    end
  end
end
