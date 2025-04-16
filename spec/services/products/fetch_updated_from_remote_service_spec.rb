# frozen_string_literal: true

require "rails_helper"

describe Products::FetchUpdatedFromRemoteService do
  let(:barcode) { "0190646641016" }
  let!(:product) { create(:product, barcode: barcode, name: nil, created_at: 2.days.ago, updated_at: 2.days.ago) }
  let(:data) {
    data = JSON.parse(Rails.root.join("spec/fixtures/files/webmock/foodrepo/products/updated_after.json").read)
    products_data = data.dig("hits", "hits").filter_map { |hit| hit["_source"] }
    products_data.map do |product_data|
      Foodrepo::Product::ParseService.new(data: product_data).call
    end
  }
  let(:adapter) { instance_double(Foodrepo::ProductAdapter) }
  let(:update_from_remote_service) { instance_double(Products::UpdateFromRemoteService) }
  let(:service) { described_class.new(adapter: adapter) }

  before do
    allow(adapter).to receive(:updated_after).and_return(data)
    allow(Products::UpdateFromRemoteService)
      .to receive(:new)
      .and_return(update_from_remote_service)
    allow(update_from_remote_service).to receive(:call)
  end

  describe "#call(updated_at: nil)", :freeze_time do
    it do
      service.call(updated_at: nil)
      expect(Products::UpdateFromRemoteService)
        .to have_received(:new).with(adapter: adapter, product: product, update_remote: false).once
      expect(update_from_remote_service).to have_received(:call).with(data: data.first).once
    end
  end
end
