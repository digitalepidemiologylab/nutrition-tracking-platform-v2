# frozen_string_literal: true

module Collab
  module Annotations
    class OpeningsController < BaseController
      before_action :set_annotation

      def create
        @annotation.open_annotation!
        flash[:notice] = t(".success")
      rescue AASM::InvalidTransition
        flash[:alert] = t(".failure")
      ensure
        redirect_to collab_annotation_path(@annotation)
      end

      private def set_annotation
        @annotation = Annotation.find(params[:annotation_id])
        authorize(@annotation, policy_class: Collab::Annotations::OpeningPolicy)
      end
    end
  end
end
