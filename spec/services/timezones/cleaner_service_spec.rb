# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Timezones::CleanerService) do
  describe "#call" do
    before { allow(Sentry).to receive(:capture_message) }

    context "with valid timezone" do
      let(:timezone) { "Europe/Zurich" }

      it do
        expect(described_class.new(timezone).call).to eq("Europe/Zurich")
        expect(Sentry).not_to have_received(:capture_message)
      end
    end

    context "with not valid timezone" do
      let(:timezone) { "abc/def" }

      it {
        expect(described_class.new(timezone).call).to eq("UTC")
        expect(Sentry).to have_received(:capture_message)
      }
    end

    context "with America/Ciudad_Juarez timezone" do
      let(:timezone) { "America/Ciudad_Juarez" }

      it do
        expect(described_class.new(timezone).call).to eq("America/Denver")
        expect(Sentry).not_to have_received(:capture_message)
      end
    end

    context "with no timezone" do
      let(:timezone) { nil }

      it do
        expect(described_class.new(timezone).call).to be_nil
        expect(Sentry).not_to have_received(:capture_message)
      end
    end
  end
end
