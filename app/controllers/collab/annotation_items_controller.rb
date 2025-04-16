# frozen_string_literal: true

module Collab
  class AnnotationItemsController < BaseController
    before_action :set_annotation_item, only: %i[update destroy]
    before_action :set_associated_items, only: %i[update]

    def update
      @annotation = @annotation_item.annotation
      @annotation_items = @annotation.annotation_items
        .includes(:polygon_set, :food, :product)
        .order(created_at: :desc)
      form = ::AnnotationItemForm.new(annotation_item: @annotation_item)
      if !form.save(annotation_item_permitted_params)
        @annotation_item = form.annotation_item
        flash.now[:alert] = t(".failure")
      end
    end

    def destroy
      @annotation = @annotation_item.annotation
      @annotation_items = @annotation.annotation_items
        .includes(:present_unit, :consumed_unit, :polygon_set, :product, food: :translations)
        .order(position: :desc)
      if !@annotation_item.destroy
        flash.now[:alert] = t(".failure")
      end
    end

    private def set_annotation_item
      @annotation_item = AnnotationItem.find(params[:id])
      authorize(@annotation_item)
    end

    private def set_associated_items
      @units = Unit.g_and_ml
    end

    private def annotation_item_permitted_params
      permitted_attributes(@annotation_item).except(:id)
    end
  end
end
