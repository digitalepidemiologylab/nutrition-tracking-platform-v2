# frozen_string_literal: true

module Collab
  class CollaborationPolicy < BasePolicy
    def edit?
      update?
    end

    def update?
      collaborator.admin? || manager?(cohort: record.cohort)
    end

    def permitted_attributes
      %i[role]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          managed_cohorts = Cohort.joins(:collaborations).merge(collaborator.collaborations.where(role: :manager))
          scope
            .where(collaborator: collaborator).active
            .or(scope.where(cohort: managed_cohorts))
        end
      end
    end
  end
end
