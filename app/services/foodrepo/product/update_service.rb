# frozen_string_literal: true

module Foodrepo
  module Product
    class UpdateService
      def initialize(product:, update_remote: false)
        @product = product
        @update_remote = update_remote
      end

      def call(data:)
        foodrepo_id = data.fetch(:foodrepo_id, nil)
        product_data = data.fetch(:data, {})
        status = data.fetch(:status, nil)

        case status
        when "complete"
          update_complete(product_data: product_data)
        when "incomplete"
          update_incomplete(foodrepo_id: foodrepo_id, product_data: product_data)
        else
          create_incomplete
        end
      end

      private def adapter
        return unless @update_remote

        @adapter ||= Foodrepo::ProductAdapter.new(product: @product)
      end

      private def update_complete(product_data:)
        @product.transaction do
          @product.product_nutrients.destroy_all
          @product.update!(product_data)
          @product.mark_complete! unless @product.incomplete?
        end
      end

      private def update_incomplete(foodrepo_id:, product_data:)
        @product.transaction do
          adapter&.update(foodrepo_id: foodrepo_id)
          @product.product_nutrients.destroy_all
          @product.update!(product_data)
          @product.mark_incomplete! unless @product.incomplete?
        end
      end

      private def create_incomplete
        @product.transaction do
          adapter&.create
          @product.mark_incomplete!
        end
      end
    end
  end
end
