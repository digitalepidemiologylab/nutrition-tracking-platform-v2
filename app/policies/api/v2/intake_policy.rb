# frozen_string_literal: true

module Api
  module V2
    class IntakePolicy < BasePolicy
      def index?
        true
      end

      def create?
        user == record.annotation&.dish&.user
      end

      def update?
        user == record.annotation&.dish&.user
      end

      def destroy?
        user == record.annotation&.dish&.user
      end

      def permitted_attributes
        [
          :id,
          :type,
          attributes: %i[consumed_at timezone]
        ]
      end

      def permitted_includes
        %w[
          annotation
          annotation.dish
          annotation.dish.dish_image
          annotation.comments
          annotation.annotation_items
          annotation.annotation_items.food
          annotation.annotation_items.product
          annotation.annotation_items.product.product_images
        ]
      end

      class Scope < Scope
        def resolve
          scope
            .where(annotation: Annotation.joins(:dish).where(dish: {user: user}))
        end
      end
    end
  end
end
