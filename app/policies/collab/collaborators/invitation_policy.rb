# frozen_string_literal: true

module Collab
  module Collaborators
    class InvitationPolicy < BasePolicy
      def new?
        create?
      end

      def create?
        collaborator.admin? || manager?(cohort: record)
      end
    end
  end
end
