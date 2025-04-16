# frozen_string_literal: true

module Collab
  class AnnotationProductsController < AnnotationItemsController
    before_action :set_associated_items, only: %i[create]

    def create
      @annotation = Annotation.find(params[:annotation_id])
      @annotation_items = @annotation.annotation_items
        .includes(:polygon_set, :food, :product)
        .order(created_at: :desc)
      @annotation_item = @annotation.annotation_items.new
      authorize(@annotation_item)
      form = ::AnnotationItemForm.new(annotation_item: @annotation_item)
      if !form.save
        @annotation_item = form.annotation_item
        flash.now[:alert] = t("collab.annotation_items.update.failure")
      end
    end
  end
end
