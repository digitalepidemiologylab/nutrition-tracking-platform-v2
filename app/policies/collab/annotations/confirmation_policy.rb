# frozen_string_literal: true

module Collab
  module Annotations
    class ConfirmationPolicy < BasePolicy
      def create?
        collaborator.admin? || manager_or_annotator?(cohort: record.cohort)
      end
    end
  end
end
