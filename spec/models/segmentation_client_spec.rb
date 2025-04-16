# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SegmentationClient) do
  describe "Associations" do
    let(:segmentation_client) { build(:segmentation_client) }

    it do
      expect(segmentation_client).to have_many(:cohorts).inverse_of(:segmentation_client).dependent(:restrict_with_error)
      expect(segmentation_client).to have_many(:polygon_sets).inverse_of(:segmentation_client).dependent(:destroy)
      expect(segmentation_client).to have_many(:segmentations).inverse_of(:segmentation_client).dependent(:restrict_with_error)
    end
  end

  describe "Validations" do
    let(:segmentation_client) { create(:segmentation_client) }

    it do
      expect(segmentation_client).to be_valid
      expect(segmentation_client).to validate_presence_of(:name)
      expect(segmentation_client).to validate_uniqueness_of(:name)
      expect(segmentation_client).to validate_presence_of(:ml_model)
      expect(segmentation_client).to validate_uniqueness_of(:ml_model)
    end
  end
end
