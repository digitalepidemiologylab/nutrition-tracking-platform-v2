# frozen_string_literal: true

module Collab
  class DishPolicy < BasePolicy
    def index?
      collaborator.admin? || manager_or_annotator?(cohort: :any)
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(participations: {cohort: :collaborations})
            .merge(CollaborationPolicy::Scope.new(collaborator, Collaboration).resolve)
        end
      end
    end
  end
end
