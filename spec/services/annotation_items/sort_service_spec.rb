# frozen_string_literal: true

require "rails_helper"

describe(AnnotationItems::SortService) do
  let(:annotation) { create(:annotation, :with_annotation_items) }
  let(:annotation_item_1) { annotation.annotation_items.first }
  let(:annotation_item_2) { annotation.annotation_items.second }

  let(:sort_service) { described_class.new(annotation_item: annotation_item_2) }

  describe "#call" do
    it do
      expect { sort_service.call(position: 2) }
        .to change(annotation_item_2.reload, :position).from(2).to(1)
    end
  end
end
