# frozen_string_literal: true

module Collab
  module Images
    class GalleryComponent < ApplicationComponent
      renders_many :images, "ImageComponent"

      def render?
        images.any?
      end

      class ImageComponent < ApplicationComponent
        def initialize(image_url: nil, image: nil)
          @image = image_url.presence || image&.data&.variant(:thumb)
          @image_url = image_url.presence || image&.data
        end

        def render?
          @image.present?
        end
      end
    end
  end
end
