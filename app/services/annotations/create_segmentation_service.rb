# frozen_string_literal: true

module Annotations
  class CreateSegmentationService
    def initialize(annotation:)
      @annotation = annotation
    end

    def call
      dish_image = @annotation.dish.dish_image
      @annotation.create_segmentation!(
        dish_image: dish_image,
        segmentation_client: segmentation_client
      )
    end

    private def segmentation_client
      @annotation.participation.cohort.segmentation_client
    end
  end
end
