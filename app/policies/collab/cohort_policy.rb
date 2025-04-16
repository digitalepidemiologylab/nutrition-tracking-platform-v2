# frozen_string_literal: true

module Collab
  class CohortPolicy < BasePolicy
    def index?
      collaborator.admin? || manager?(cohort: :any)
    end

    def show?
      collaborator.admin? || manager?(cohort: record)
    end

    def new?
      create?
    end

    def create?
      collaborator.admin?
    end

    def edit?
      update?
    end

    def update?
      collaborator.admin? || manager?(cohort: record)
    end

    def permitted_attributes
      [:name, :segmentation_client_id, food_list_ids: []]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(:collaborations)
            .where(collaborations: CollaborationPolicy::Scope.new(collaborator, Collaboration).resolve)
            .distinct
        end
      end
    end
  end
end
