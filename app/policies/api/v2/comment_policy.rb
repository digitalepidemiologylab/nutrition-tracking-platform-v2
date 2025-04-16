# frozen_string_literal: true

module Api
  module V2
    class CommentPolicy < BasePolicy
      def index?
        true
      end

      def create?
        user == record.dish.user
      end

      def permitted_attributes
        [
          :id,
          :type,
          attributes: %i[message]
        ]
      end

      def permitted_includes
        %w[annotation]
      end

      class Scope < Scope
        def resolve
          scope
            .joins(annotation: :dish)
            .merge(Dish.where(user: user))
        end
      end
    end
  end
end
