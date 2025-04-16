# frozen_string_literal: true

module Annotations
  class FoodImagesGalleryQuery
    def initialize(food:, initial_scope:)
      @food = food
      @initial_scope = initial_scope
    end

    def query
      @initial_scope
        .select("annotations.*", "COUNT(DISTINCT(count_annotation_items.id)) AS annotation_items_count")
        .joins("
          INNER JOIN annotation_items count_annotation_items
          ON count_annotation_items.annotation_id = annotations.id
        ")
        .joins(:annotation_items, dish: :dish_image)
        .merge(AnnotationItem.where(food: @food))
        .includes(dish: {dish_image: {data_attachment: :blob}})
        .group("annotations.id")
        .order("annotation_items_count ASC, RANDOM()")
        .limit(24)
    end
  end
end
