# frozen_string_literal: true

module Api
  module V2
    class MePolicy < BasePolicy
      def show?
        true
      end

      def destroy?
        true
      end
    end
  end
end
