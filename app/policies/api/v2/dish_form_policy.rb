# frozen_string_literal: true

module Api
  module V2
    class DishFormPolicy < BasePolicy
      def create?
        user == record.user
      end

      def permitted_attributes
        [
          :type,
          attributes: {
            dish: %i[id description],
            dish_image: :data,
            intake: %i[id consumed_at timezone],
            product: :barcode,
            product_images: [[:data]]
          }
        ]
      end

      def permitted_includes
        %w[
          annotation
          annotation.intakes
          annotation.dish
          annotation.dish.dish_image
          annotation.comments
          annotation.annotation_items
          annotation.annotation_items.food
          annotation.annotation_items.product
          annotation.annotation_items.product.product_images
        ]
      end
    end
  end
end
