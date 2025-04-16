# frozen_string_literal: true

module Collab
  class ParticipationPolicy < BasePolicy
    def index?
      collaborator.admin? || manager?(cohort: :any)
    end

    def show?
      collaborator.admin? || manager?(cohort: record.cohort)
    end

    def new?
      show?
    end

    def edit?
      show?
    end

    def create?
      show?
    end

    def update?
      show?
    end

    def destroy?
      show?
    end

    def permitted_attributes
      [:ended_at]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(:cohort)
            .merge(CohortPolicy::Scope.new(collaborator, Cohort).resolve)
        end
      end
    end
  end
end
