# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Public::HealthChecksController) do
  describe "#show" do
    context "when successful" do
      it do
        get health_check_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when failed" do
      before { allow_any_instance_of(HealthCheckService).to receive(:call).and_raise(RedisClient::Error) }

      it do
        get health_check_path
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
