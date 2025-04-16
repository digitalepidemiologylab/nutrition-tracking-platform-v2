# frozen_string_literal: true

module Collab
  module Collaborations
    class DeactivationsController < BaseController
      before_action :set_collaboration

      def create
        if @collaboration.deactivate
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = @collaboration.errors.full_messages.to_sentence
        end
      end

      def destroy
        if @collaboration.reactivate
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = @collaboration.errors.full_messages.to_sentence
        end
      end

      private def set_collaboration
        @collaboration = Collaboration.find(params[:collaboration_id])
        authorize(@collaboration, policy_class: Collab::Collaborations::DeactivationPolicy)
      end
    end
  end
end
