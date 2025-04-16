# frozen_string_literal: true

module AnnotationItems
  class SortService
    def initialize(annotation_item:)
      @annotation_item = annotation_item
    end

    def call(position:)
      Rails.logger.info("AnnotationItems::SortService#call: position: #{position}")
      annotation = @annotation_item.annotation
      annotation_items = annotation.annotation_items.select(:position).order(position: :desc)
      item_at_position = annotation_items[position - 1]
      @annotation_item.insert_at(item_at_position.position)
    end
  end
end
