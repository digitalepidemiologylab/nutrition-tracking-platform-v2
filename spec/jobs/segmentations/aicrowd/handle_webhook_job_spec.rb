# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Segmentations::Aicrowd::HandleWebhookJob) do
  let!(:segmentation) { create(:segmentation) }
  let(:response) {
    JSON.parse(file_fixture("webmock/aicrowd/webhook.json").read).fetch("_json").to_json
  }
  let(:service) { instance_double(Segmentations::Aicrowd::HandleResponseService) }
  let(:job) { described_class.new }

  before do
    allow(Segmentations::Aicrowd::HandleResponseService).to receive(:new).and_return(service)
    allow(service).to receive(:call)
    segmentation.request!
  end

  describe "#perform(segmentation:, response:)" do
    it do
      job.perform(segmentation: segmentation, webhook_params: response)
      expect(Segmentations::Aicrowd::HandleResponseService).to have_received(:new).with(segmentation: segmentation)
      expect(service).to have_received(:call).with(response: Segmentations::Aicrowd::WebhookResponse.new(code: 200, body: response))
    end
  end
end
