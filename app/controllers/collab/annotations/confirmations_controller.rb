# frozen_string_literal: true

module Collab
  module Annotations
    class ConfirmationsController < BaseController
      before_action :set_annotation

      def create
        @annotation.confirm!
        flash[:notice] = t(".success")
        redirect_to collab_annotations_path_with_query_params
      rescue
        errors = @annotation.errors.full_messages
        flash[:alert] = t(".failure", messages: errors.join(", "))
        render status: :unprocessable_entity
      end

      private def set_annotation
        @annotation = Annotation.find(params[:annotation_id])
        authorize(@annotation, policy_class: Collab::Annotations::ConfirmationPolicy)
      end
    end
  end
end
