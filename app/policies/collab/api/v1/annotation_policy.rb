# frozen_string_literal: true

module Collab
  module Api
    module V1
      class AnnotationPolicy < BasePolicy
        def index?
          Collab::AnnotationPolicy.new(collaborator, record).index?
        end

        def permitted_includes
          %w[
            dish
            dish.dish_image
            intakes
            comments
            annotation_items
            annotation_items.food
            annotation_items.food.food_nutrients
            annotation_items.product
            annotation_items.product.product_nutrients
            annotation_items.product.product_images
          ]
        end

        class Scope < Scope
          def resolve
            Collab::AnnotationPolicy::Scope.new(collaborator, scope).resolve
          end
        end
      end
    end
  end
end
