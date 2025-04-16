# frozen_string_literal: true

module Segmentations
  class StartJob < ApplicationJob
    queue_as :default

    def perform(segmentation:)
      ::Aicrowd::TaskAdapter.new(segmentation: segmentation).create
    end
  end
end
