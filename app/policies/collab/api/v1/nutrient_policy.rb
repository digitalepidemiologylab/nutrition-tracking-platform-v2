# frozen_string_literal: true

module Collab
  module Api
    module V1
      class NutrientPolicy < BasePolicy
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
end
