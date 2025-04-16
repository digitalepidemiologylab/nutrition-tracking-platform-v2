# frozen_string_literal: true

module Segmentations
  module Aicrowd
    class HandleResponseService
      def initialize(segmentation:)
        @segmentation = segmentation
      end

      def call(response:)
        json_body = parse_response_body(response)
        status = json_body.fetch(:status, nil)

        case status
        when "MFR.Job.QUEUED", "MFR.Job.IN_PROGRESS"
          ActiveRecord::Base.transaction do
            update_segmentation(response)
            @segmentation.request!
          end
        when "MFR.Job.SUCCESS"
          ActiveRecord::Base.transaction do
            update_segmentation(response)
            @segmentation.receive!
          end
          Segmentations::Aicrowd::ParseJob.perform_later(segmentation: @segmentation)
        else
          ActiveRecord::Base.transaction do
            update_segmentation(response)
            @segmentation.fail!("service_error")
          end
        end

        # No further logic here as we're waiting to receive the webhook from AIcrowd service
      end

      private def update_segmentation(response)
        json_body = parse_response_body(response)
        task_id = json_body.fetch(:job_id)
        @segmentation.update!(
          task_id: task_id,
          response_code: response.code,
          response_body: json_body,
          ai_model: ai_model_name(json_body),
          response_at: Time.current
        )
      end

      private def ai_model_name(json_body)
        [json_body[:api_version], json_body[:model_identifier]].compact.join(" ")
      end

      private def parse_response_body(response)
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
