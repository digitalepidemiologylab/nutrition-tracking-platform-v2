# frozen_string_literal: true

module Aicrowd
  class TaskAdapter
    include HTTParty
    include Rails.application.routes.url_helpers

    # HTTParty config
    base_uri(ENV.fetch("AICROWD_API_BASE_URI"))

    def initialize(segmentation:)
      @segmentation = segmentation
    end

    def create
      body = {
        image_url: url_for(@segmentation.dish_image.data),
        model_id: @segmentation.segmentation_client.ml_model,
        webhook_url: segmentation_webhook_url(@segmentation.id, format: "json")
      }.to_json
      response = self.class.post("/enqueue", body: body)
      handle_response(response)
    end

    def read
      response = self.class.get("/status/#{@segmentation.task_id}")
      handle_response(response)
    end

    private def handle_response(response)
      Segmentations::Aicrowd::HandleResponseService.new(segmentation: @segmentation).call(response: response)
    end
  end
end
