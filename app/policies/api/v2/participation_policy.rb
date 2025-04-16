# frozen_string_literal: true

module Api
  module V2
    class ParticipationPolicy < BasePolicy
      def index?
        true
      end

      def permitted_attributes
        [:key]
      end

      def permitted_includes
        %w[cohort]
      end

      class Scope < Scope
        def resolve
          scope.where(user: user)
        end
      end
    end
  end
end
