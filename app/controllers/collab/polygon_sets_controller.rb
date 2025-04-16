# frozen_string_literal: true

module Collab
  class PolygonSetsController < BaseController
    before_action :set_annotation_item, only: %i[update destroy]

    def update
      if !@polygon_set.update(permitted_attributes(@polygon_set))
        flash.now[:alert] = t(".failure")
      end
    end

    def destroy
      if !@polygon_set.destroy
        flash.now[:alert] = t(".failure")
      end
    end

    private def set_annotation_item
      @annotation_item = AnnotationItem.find(params[:annotation_item_id])
      @polygon_set = @annotation_item.polygon_set || @annotation_item.build_polygon_set
      authorize(@polygon_set)
    end
  end
end
