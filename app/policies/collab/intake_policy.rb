# frozen_string_literal: true

module Collab
  class IntakePolicy < BasePolicy
    def index?
      collaborator.admin? || manager?(cohort: :any)
    end

    def permitted_sort_attributes
      %w[
        intakes.consumed_at
        annotations.status
      ]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(annotation: :dish)
            .merge(DishPolicy::Scope.new(collaborator, Dish).resolve)
        end
      end
    end
  end
end
