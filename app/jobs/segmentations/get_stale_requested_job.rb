# frozen_string_literal: true

module Segmentations
  class GetStaleRequestedJob < ApplicationJob
    queue_as :default

    def perform(segmentation:)
      adapter = ::Aicrowd::TaskAdapter.new(segmentation: segmentation)
      adapter.read
    end
  end
end
