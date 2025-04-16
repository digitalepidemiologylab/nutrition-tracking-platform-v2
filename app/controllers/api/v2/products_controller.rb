# frozen_string_literal: true

module Api
  module V2
    class ProductsController < BaseController
      MAX_ITEMS = 1000

      def index
        authorize(Product)
        products = policy_scope(Product)
        pagy, products = pagy(products, max_items: MAX_ITEMS)
        render jsonapi: products,
          fields: {products: [:barcode]},
          meta: pagy_metadata(pagy),
          status: :ok
      end
    end
  end
end
