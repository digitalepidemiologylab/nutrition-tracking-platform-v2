# frozen_string_literal: true

module Public
  module Segmentations
    # see https://aicrowd-api.myfoodrepo.org for API doc
    class WebhooksController < BaseController
      skip_before_action :verify_authenticity_token
      skip_before_action :http_auth

      def create
        segmentation = Segmentation.find(params[:segmentation_id])
        ::Segmentations::Aicrowd::HandleWebhookJob.perform_later(
          segmentation: segmentation,
          webhook_params: webhook_params.to_s
        )
        render json: {}, status: :ok
      end

      private def webhook_params
        params.require(:_json)
      end
    end
  end
end
