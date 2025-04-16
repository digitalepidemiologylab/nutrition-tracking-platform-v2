# frozen_string_literal: true

require "rails_helper"
RSpec.describe(Segmentations::Aicrowd::ParseJob) do
  let!(:segmentation) { create(:segmentation) }
  let!(:parse_service) { instance_double(Segmentations::Aicrowd::ParseService) }
  let(:job) { described_class.new }

  before do
    allow(Segmentations::Aicrowd::ParseService)
      .to receive(:new).and_return(parse_service)
    allow(parse_service).to receive(:call).with(no_args)
  end

  describe "#perform" do
    it do
      job.perform(segmentation: segmentation)
      expect(Segmentations::Aicrowd::ParseService).to have_received(:new).with(segmentation: segmentation)
      expect(parse_service).to have_received(:call).with(no_args)
    end
  end
end
