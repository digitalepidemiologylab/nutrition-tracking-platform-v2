# frozen_string_literal: true

module Collab
  module AnnotationItems
    class SortsController < BaseController
      def update
        annotation_item = AnnotationItem.find(params[:annotation_item_id])
        authorize(annotation_item, :update?, policy_class: Collab::AnnotationItemPolicy)
        sort_service = ::AnnotationItems::SortService.new(annotation_item: annotation_item)
        if sort_service.call(position: params[:position].to_i)
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = t(".failure")
        end
      end
    end
  end
end
