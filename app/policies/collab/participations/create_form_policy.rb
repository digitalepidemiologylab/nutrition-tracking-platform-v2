# frozen_string_literal: true

module Collab
  module Participations
    class CreateFormPolicy < BasePolicy
      def create?
        manager?(cohort: record.cohort) || collaborator.admin?
      end

      def permitted_attributes
        :number
      end
    end
  end
end
