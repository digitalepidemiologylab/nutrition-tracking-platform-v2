# frozen_string_literal: true

module Collab
  class AnnotationPolicy < BasePolicy
    def index?
      collaborator.admin? || manager_or_annotator?(cohort: :any)
    end

    def show?
      collaborator.admin? || manager_or_annotator?(cohort: record.cohort)
    end

    def update?
      show?
    end

    def annotatable?
      update? && (record.annotatable? || record.info_asked?)
    end

    def permitted_sort_attributes
      [
        "status",
        "dishes.id",
        "intakes.consumed_at",
        "updated_at"
      ]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .where(participation: ParticipationPolicy::Scope.new(collaborator, Participation).resolve)
        end
      end
    end
  end
end
