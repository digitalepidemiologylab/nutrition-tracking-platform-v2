# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Public::Segmentations::WebhooksController) do
  let!(:segmentation) { create(:segmentation) }
  let(:params) { JSON.parse(file_fixture("webmock/aicrowd/webhook.json").read) }

  describe "#create" do
    it do
      expect { post segmentation_webhook_path(segmentation.id, params: params, format: :json) }
        .to have_enqueued_job(Segmentations::Aicrowd::HandleWebhookJob)
      expect(response).to have_http_status(:ok)
    end
  end
end
