# frozen_string_literal: true

module Products
  class FetchDataJob < ApplicationJob
    queue_as :default

    def perform(product:)
      adapter = Foodrepo::ProductAdapter.new(product: product)
      Products::UpdateFromRemoteService
        .new(adapter: adapter, product: product, update_remote: true)
        .call
    end
  end
end
