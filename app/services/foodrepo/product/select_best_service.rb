# frozen_string_literal: true

module Foodrepo
  module Product
    class SelectBestService
      def initialize(products:)
        @products = products
      end

      def call
        return nil if @products.blank?
        return @products.first if @products.size == 1

        product = @products.detect { |product| product["status"] == "complete" }
        return product if product.present?

        @products.max_by { |product| product["nutrients"].size }
      end
    end
  end
end
