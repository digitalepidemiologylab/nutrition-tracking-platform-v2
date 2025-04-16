# frozen_string_literal: true

module Segmentations
  module Aicrowd
    class ParseJob < ApplicationJob
      queue_as :default

      def perform(segmentation:)
        Segmentations::Aicrowd::ParseService.new(segmentation: segmentation).call
      end
    end
  end
end
