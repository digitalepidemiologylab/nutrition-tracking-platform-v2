# frozen_string_literal: true

require "rails_helper"

describe Segmentations::GetStaleRequestedService do
  let!(:segmentation_stale_1) { create(:segmentation, :requested, updated_at: 120.minutes.ago) }
  let!(:segmentation_stale_2) { create(:segmentation, :requested, updated_at: 59.minutes.ago) }
  let!(:segmentation_stale_3) { create(:segmentation, :requested, updated_at: 181.minutes.ago) }
  let!(:segmentation_stale_4) { create(:segmentation, :requested, updated_at: 60.minutes.ago) }
  let(:service) { described_class.new }

  describe "#call" do
    it do
      expect(service.call).to eq([segmentation_stale_1, segmentation_stale_4])
    end
  end
end
