# frozen_string_literal: true

require "rails_helper"

describe(Segmentations::StartJob) do
  let(:segmentation) { create(:segmentation) }
  let(:adapter) { instance_double(Aicrowd::TaskAdapter) }
  let(:response_service) { instance_double(Segmentations::Aicrowd::HandleResponseService) }
  let(:service_response) {
    JSON.parse(file_fixture("webmock/aicrowd/task_created.json").read)
  }
  let(:job) { described_class.new }

  describe "#perform" do
    before do
      allow(Aicrowd::TaskAdapter)
        .to receive(:new).and_return(adapter)
      allow(adapter).to receive(:create).and_return(service_response)
      allow(Segmentations::Aicrowd::HandleResponseService)
        .to receive(:new)
        .with(segmentation: segmentation)
        .and_return(response_service)
      allow(response_service).to receive(:call).with(response: service_response)
    end

    it do
      job.perform(segmentation: segmentation)
      expect(Aicrowd::TaskAdapter)
        .to have_received(:new).with(segmentation: segmentation)
      expect(adapter)
        .to have_received(:create).with(no_args)
    end
  end
end
