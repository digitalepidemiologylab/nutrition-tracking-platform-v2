# frozen_string_literal: true

module Api
  module V2
    class ProductPolicy < BasePolicy
      def index?
        true
      end

      class Scope < Scope
        def resolve
          scope.all
        end
      end
    end
  end
end
