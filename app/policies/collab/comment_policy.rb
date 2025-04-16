# frozen_string_literal: true

module Collab
  class CommentPolicy < BasePolicy
    def index?
      collaborator.admin? || manager_or_annotator?(cohort: :any)
    end

    def create?
      Collab::AnnotationPolicy.new(collaborator, record.annotation).annotatable?
    end

    def permitted_attributes
      %i[message silent]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(:annotation)
            .merge(AnnotationPolicy::Scope.new(collaborator, Annotation).resolve)
            .distinct
        end
      end
    end
  end
end
