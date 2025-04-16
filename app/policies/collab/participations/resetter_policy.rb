# frozen_string_literal: true

module Collab
  module Participations
    class ResetterPolicy < BasePolicy
      def create?
        manager?(cohort: record.cohort) || collaborator.admin?
      end
    end
  end
end
