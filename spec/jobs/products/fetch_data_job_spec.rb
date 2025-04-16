# frozen_string_literal: true

require "rails_helper"

describe(Products::FetchDataJob) do
  let(:product) { create(:product) }
  let(:job) { described_class.new }
  let(:adapter) { instance_double(Foodrepo::ProductAdapter) }
  let(:service) { instance_double(Products::UpdateFromRemoteService) }

  before do
    allow(Foodrepo::ProductAdapter).to receive(:new).and_return(adapter)
    allow(Products::UpdateFromRemoteService).to receive(:new).and_return(service)
    allow(service).to receive(:call).with(no_args)
  end

  describe "#perform" do
    it do
      job.perform(product: product)
      expect(Foodrepo::ProductAdapter).to have_received(:new).with(product: product)
      expect(Products::UpdateFromRemoteService).to have_received(:new).with(adapter: adapter, product: product, update_remote: true)
      expect(service).to have_received(:call).with(no_args)
    end
  end
end
