# frozen_string_literal: true

require "rails_helper"

describe(Annotations::CreateSegmentationService) do
  let(:participation) { create(:participation) }
  let(:segmentation_client) { participation.cohort.segmentation_client }
  let!(:dish) { create(:dish, :with_dish_image, user: participation.user) }
  let(:annotation) { create(:annotation, participation: participation, dish: dish) }
  let(:create_segmentation_service) { described_class.new(annotation: annotation) }

  describe "#call" do
    it "creates a segmentation" do
      expect { create_segmentation_service.call }
        .to change(Segmentation, :count).by(1)
        .and(change(annotation, :segmentation).from(nil).to(an_instance_of(Segmentation)))
      expect(annotation.segmentation.segmentation_client).to eq(segmentation_client)
    end
  end
end
