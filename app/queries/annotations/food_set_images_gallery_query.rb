# frozen_string_literal: true

module Annotations
  class FoodSetImagesGalleryQuery
    def initialize(food_set:, initial_scope:)
      @food_set = food_set
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
        .merge(AnnotationItem.includes({food: :food_food_sets}).where(foods: {food_food_sets: {food_set: @food_set}}))
        .includes(dish: {dish_image: {data_attachment: :blob}})
        .group(
          "annotations.id", "annotation_items.id", "foods.id", "food_food_sets.id", "dishes.id", "dish_images.id",
          "active_storage_attachments.id", "active_storage_blobs.id"
        )
        .order("annotation_items_count ASC, RANDOM()")
        .limit(24)
    end
  end
end
