# frozen_string_literal: true

require "rails_helper"

describe Products::UpdateFromRemoteService do
  # Use Coke barcode
  let(:barcode) { "5449000009500" }
  let(:foodrepo_id) { 22784 }
  let(:product) { create(:product, barcode: barcode) }
  let(:service) { described_class.new(adapter: adapter, product: product) }

  describe "#call", :freeze_time do
    context "when adapter is Foodrepo::ProductAdapter" do
      let(:data) { instance_double(Hash) }
      let(:adapter) { Foodrepo::ProductAdapter.new }
      let(:update_service) { instance_double(Foodrepo::Product::UpdateService) }

      before do
        allow(adapter).to receive(:fetch).and_return(data)
        allow(Foodrepo::Product::UpdateService).to receive(:new).and_return(update_service)
        allow(update_service).to receive(:call)
      end

      it do
        service.call
        expect(update_service).to have_received(:call).with(data: data)
      end
    end

    context "when adapter is unknown" do
      let(:data) { instance_double(Hash) }
      let(:adapter) { Struct.new(:fetch).new }
      let(:update_service) { instance_double(Foodrepo::Product::UpdateService) }

      before do
        allow(adapter).to receive(:fetch).and_return(data)
        allow(Foodrepo::Product::UpdateService).to receive(:new).and_return(update_service)
        allow(update_service).to receive(:call)
      end

      it do
        expect { service.call }
          .to raise_error(described_class::InvalidArgumentError, "Unknown Product adapter")
      end
    end
  end
end
