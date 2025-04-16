# frozen_string_literal: true

require "rails_helper"

describe(Annotations::CreateSegmentationJob) do
  let(:annotation) { create(:annotation) }
  let(:job) { described_class.new }

  describe "#perform" do
    let(:create_segmentation_service) { instance_double(Annotations::CreateSegmentationService) }

    before do
      allow(Annotations::CreateSegmentationService)
        .to receive(:new)
        .and_return(create_segmentation_service)
      allow(create_segmentation_service).to receive(:call)
    end

    it do
      job.perform(annotation: annotation)
      expect(Annotations::CreateSegmentationService)
        .to have_received(:new)
        .with(annotation: annotation)
      expect(create_segmentation_service)
        .to have_received(:call).with(no_args)
    end
  end
end
