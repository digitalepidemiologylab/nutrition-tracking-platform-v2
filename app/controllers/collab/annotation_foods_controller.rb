# frozen_string_literal: true

module Collab
  class AnnotationFoodsController < AnnotationItemsController
    before_action :set_associated_items, only: %i[create]

    def create
      @annotation = Annotation.find(params[:annotation_id])
      @annotation_items = @annotation.annotation_items
        .includes(:polygon_set, :food, :product)
        .order(created_at: :desc)
      # Returns a unique food for this annotation (prevent creation of items with the
      # same food for the same annotation).
      food = policy_scope(Food)
        .i18n
        .of_food_lists(@annotation.food_lists)
        .where.not(id: @annotation.annotation_items.pluck(:food_id))
        .order(:name)
        .first
      @annotation_item = @annotation.annotation_items.new(food: food)
      authorize(@annotation_item)
      form = ::AnnotationItemForm.new(annotation_item: @annotation_item)
      if !form.save
        @annotation_item = form.annotation_item
        flash.now[:alert] = t("collab.annotation_items.update.failure")
      end
    end
  end
end
