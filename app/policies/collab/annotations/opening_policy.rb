# frozen_string_literal: true

module Collab
  module Annotations
    class OpeningPolicy < BasePolicy
      def create?
        record&.annotated? &&
          (collaborator.admin? || manager_or_annotator?(cohort: record.cohort))
      end
    end
  end
end
