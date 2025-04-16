# frozen_string_literal: true

module Collab
  module Participations
    class ResettersController < BaseController
      def create
        @participation = Participation.find(params[:participation_id])
        authorize(@participation, policy_class: Collab::Participations::ResetterPolicy)
        resetter = ::Participations::ResetService.new(participation: @participation)
        if resetter.call
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = resetter.errors.full_messages.to_sentence
        end
      end
    end
  end
end
