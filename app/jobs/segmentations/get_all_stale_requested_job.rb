# frozen_string_literal: true

module Segmentations
  class GetAllStaleRequestedJob < ApplicationJob
    include JobLoggable

    queue_as :default

    def perform
      stale_requested_segmentations = Segmentations::GetStaleRequestedService.new.call
      stale_requested_segmentations.find_each do |segmentation|
        # Use 1 job per segmentation for better tracking and error management
        Segmentations::GetStaleRequestedJob.perform_now(segmentation: segmentation)
      end
    end
  end
end
