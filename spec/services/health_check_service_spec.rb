# frozen_string_literal: true

require "rails_helper"

RSpec.describe(HealthCheckService) do
  let(:service) { described_class.new }

  describe "#call" do
    context "when success" do
      it { expect { service.call }.not_to raise_error }
    end

    context "when PostgreSQL connection can't be done" do
      before do
        allow_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          .to receive(:execute).and_raise(ActiveRecord::ConnectionTimeoutError)
      end

      it { expect { service.call }.to raise_error(ActiveRecord::ConnectionTimeoutError) }
    end

    context "when Redis connection can't be done" do
      before { allow_any_instance_of(Redis).to receive(:ping).and_raise(Redis::BaseError) }

      it { expect { service.call }.to raise_error(Redis::BaseError) }
    end
  end
end
