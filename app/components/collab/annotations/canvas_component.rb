# frozen_string_literal: true

module Collab
  module Annotations
    class CanvasComponent < ApplicationComponent
      def initialize(annotation:, annotation_item: nil, annotation_items: nil)
        @annotation = annotation
        @annotation_item = annotation_item
        @annotation_items = annotation_items
        @position = @annotation_item&.position
        @color_index = @annotation_item&.color_index
      end

      def call
        data = {
          color_index: @color_index,
          controller: "canvas",
          action: "destroyPolygons->canvas#destroyPolygons",
          "annotation-target": "canvas",
          "canvas-polygons-value": polygons_data
        }
        if @annotation_item
          data["canvas-annotation-item-id-value"] = @annotation_item.id
          data["canvas-polygons-url-value"] = collab_annotation_item_polygon_set_path(
            @annotation_item,
            locale: I18n.locale
          )
        end
        tag.canvas(
          id: dom_id(@annotation, :canvas),
          class: "absolute inset-0 z-1000",
          data: data
        )
      end

      private def polygons_data
        return unless @annotation_items

        @annotation_items.map do |ai|
          {
            id: ai.id,
            index: ai.position,
            colorIndex: ai.color_index,
            polygons: ai&.polygon_set&.polygons
          }
        end
      end
    end
  end
end
