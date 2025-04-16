# frozen_string_literal: true

module Segmentations
  module Aicrowd
    class HandleWebhookJob < ApplicationJob
      queue_as :default

      def perform(segmentation:, webhook_params:)
        Segmentations::Aicrowd::HandleResponseService
          .new(segmentation: segmentation)
          .call(response: formatted_response(response: webhook_params))
      end

      private def formatted_response(response: webhook_params)
        WebhookResponse.new(code: 200, body: response)
      end
    end

    WebhookResponse = Struct.new(:code, :body, keyword_init: true)
  end
end
