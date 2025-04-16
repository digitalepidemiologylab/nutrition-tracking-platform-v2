# frozen_string_literal: true

module Annotations
  class CreateSegmentationJob < ApplicationJob
    queue_as :default

    def perform(annotation:)
      Annotations::CreateSegmentationService.new(annotation: annotation).call
    end
  end
end
