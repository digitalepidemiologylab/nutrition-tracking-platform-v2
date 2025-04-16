# frozen_string_literal: true

require "rails_helper"

describe(Segmentations::GetAllStaleRequestedJob) do
  let!(:segmentation_1) { create(:segmentation, :requested) }
  let!(:segmentation_2) { create(:segmentation, :requested) }
  let!(:segmentation_3) { create(:segmentation, :requested) }
  let!(:get_stale_requested_service) { instance_double(Segmentations::GetStaleRequestedService) }
  let(:job) { described_class.new }

  it_behaves_like "job_loggable"

  describe "#perform(segmentation:)" do
    before do
      allow(Segmentations::GetStaleRequestedService).to receive(:new).and_return(get_stale_requested_service)
      allow(get_stale_requested_service).to receive(:call).and_return(Segmentation.where(id: [segmentation_1.id, segmentation_2.id]))
      allow(Segmentations::GetStaleRequestedJob).to receive(:perform_now)
    end

    it do
      job.perform
      expect(Segmentations::GetStaleRequestedJob).to have_received(:perform_now).with(segmentation: segmentation_1).once
      expect(Segmentations::GetStaleRequestedJob).to have_received(:perform_now).with(segmentation: segmentation_2).once
      expect(Segmentations::GetStaleRequestedJob).not_to have_received(:perform_now).with(segmentation: segmentation_3)
    end
  end
end
