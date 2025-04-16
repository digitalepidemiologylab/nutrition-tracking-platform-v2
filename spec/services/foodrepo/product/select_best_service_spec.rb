# frozen_string_literal: true

require "rails_helper"

describe(Foodrepo::Product::SelectBestService) do
  let(:data) do
    JSON.parse(file_fixture("webmock/foodrepo/products/dark_chocolate_multiple.json").read)["data"]
  end
  let(:service) { described_class.new(products: data) }

  context "when one of the product is complete" do
    it do
      expect(service.call).to eq(data.second)
    end
  end

  context "when both products are complete but one has more nutrients" do
    before { data.first["status"] = "complete" }

    it { expect(service.call).to eq(data.first) }
  end

  context "when only one product is returned" do
    before { data.pop }

    it { expect(service.call).to eq(data.first) }
  end

  context "when no products are returned" do
    before { data.clear }

    it { expect(service.call).to be_nil }
  end
end
