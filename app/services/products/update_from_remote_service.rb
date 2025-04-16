# frozen_string_literal: true

module Products
  class UpdateFromRemoteService
    def initialize(adapter:, product:, update_remote: false)
      @adapter = adapter
      @product = product
      @update_remote = update_remote
    end

    # when data is passed we don't fetch it from remote service and simply
    # use what is passed to update the product locally (for example, it happens
    # when data has been fetched in a batch request)
    def call(data: nil)
      case @adapter
      when Foodrepo::ProductAdapter
        data ||= @adapter.fetch
        update_service = Foodrepo::Product::UpdateService.new(product: @product, update_remote: @update_remote)
      else
        raise InvalidArgumentError, "Unknown Product adapter"
      end
      update_service.call(data: data)
    end

    class InvalidArgumentError < StandardError; end
  end
end
