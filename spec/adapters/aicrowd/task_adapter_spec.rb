# frozen_string_literal: true

require "rails_helper"

describe Aicrowd::TaskAdapter do
  let!(:segmentation) { create(:segmentation) }
  let(:adapter) { described_class.new(segmentation: segmentation) }
  let(:handle_response_service) { instance_double(Segmentations::Aicrowd::HandleResponseService) }

  describe "#create" do
    before do
      allow(Segmentations::Aicrowd::HandleResponseService).to receive(:new).and_return(handle_response_service)
      allow(handle_response_service).to receive(:call)
      adapter.create
    end

    it do
      expect(handle_response_service)
        .to have_received(:call)
        .with(instance_of(Hash))
    end
  end

  describe "#read" do
    before do
      allow(Segmentations::Aicrowd::HandleResponseService).to receive(:new).and_return(handle_response_service)
      allow(handle_response_service).to receive(:call)
      adapter.read
    end

    it do
      expect(handle_response_service)
        .to have_received(:call)
        .with(instance_of(Hash))
    end
  end
end
