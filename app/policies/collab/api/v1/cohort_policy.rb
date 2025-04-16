# frozen_string_literal: true

module Collab
  module Api
    module V1
      class CohortPolicy < BasePolicy
        def show?
          Collab::CohortPolicy.new(collaborator, record).show?
        end

        def permitted_includes
          %w[food_lists]
        end
      end
    end
  end
end
