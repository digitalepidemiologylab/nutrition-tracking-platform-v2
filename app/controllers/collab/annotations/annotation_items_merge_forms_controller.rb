# frozen_string_literal: true

module Collab
  module Annotations
    class AnnotationItemsMergeFormsController < BaseController
      before_action :set_annotation, :set_associated_items, only: %i[create]

      def create
        merge_form = ::Annotations::AnnotationItemsMergeForm.new(annotation: @annotation)
        authorize(merge_form)
        if merge_form.save(permitted_attributes(merge_form))
          @parent_annotation_item = merge_form.parent_annotation_item
          @merged_annotation_items = merge_form.annotation_items
          flash[:notice] = t(".success")
        else
          @parent_annotation_item = nil
          @merged_annotation_items = []
          flash.now[:alert] = (Array(t(".failure")) + merge_form.errors.full_messages).compact.join(": ")
        end
      end

      private def set_annotation
        @annotation = Annotation.find(params[:annotation_id])
      end

      private def set_associated_items
        @units = Unit.g_and_ml
      end
    end
  end
end
