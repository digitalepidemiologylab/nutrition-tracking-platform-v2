# frozen_string_literal: true

module Products
  class FetchUpdatedFromRemoteService
    def initialize(adapter:)
      @adapter = adapter
    end

    def call(updated_at: nil)
      updated_at ||= 1.month.ago
      products_data = @adapter.updated_after(datetime: updated_at)
      products_data.each do |product_data|
        product = Product.find_by(barcode: product_data[:barcode])
        next unless product

        Products::UpdateFromRemoteService
          .new(product: product, adapter: @adapter, update_remote: false)
          .call(data: product_data)
      end
    end
  end
end
