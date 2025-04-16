# frozen_string_literal: true

module Collab
  module Annotations
    class AnnotationItemsDestroyFormsController < BaseController
      before_action :set_annotation, :set_associated_items, only: %i[destroy]

      def destroy
        destroy_form = ::Annotations::AnnotationItemsDestroyForm.new(annotation: @annotation)
        authorize(destroy_form)
        if destroy_form.save(permitted_attributes(destroy_form))
          @destroyed_annotation_items = destroy_form.annotation_items
          flash[:notice] = t(".success")
        else
          @destroyed_annotation_items = []
          flash.now[:alert] = (Array(t(".failure")) + destroy_form.errors.full_messages).compact.join(": ")
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
