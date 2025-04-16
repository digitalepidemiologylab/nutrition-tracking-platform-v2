# frozen_string_literal: true

module Collab
  module Collaborations
    class DeactivationPolicy < BasePolicy
      def create?
        destroy?
      end

      def destroy?
        return false if collaborator == record.collaborator

        collaborator.admin? || manager?(cohort: record.cohort)
      end
    end
  end
end
