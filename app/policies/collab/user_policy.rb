# frozen_string_literal: true

module Collab
  class UserPolicy < BasePolicy
    def index?
      collaborator.admin? || manager?(cohort: :any)
    end

    def show?
      collaborator.admin? || manager?(cohort: record.cohorts)
    end

    def destroy?
      collaborator.admin?
    end

    def permitted_sort_attributes
      %w[email created_at]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(:participations)
            .where(participations: {
              id: ParticipationPolicy::Scope.new(collaborator, Participation).resolve
            })
        end
      end
    end
  end
end
