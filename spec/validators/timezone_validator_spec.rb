# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TimezoneValidator) do
  let(:timezone_bearer_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :timezone

      validates :timezone, timezone: true

      def initialize(timezone = nil)
        self.timezone = timezone
      end

      def self.name
        "TimezoneBearer"
      end
    end
  end

  context "when timezone is valid" do
    context "with iOS timezones" do
      let(:ios_timezones) do
        CSV.read(Rails.root.join("spec/fixtures/files/timezones/ios.csv"))
          .map(&:first)
          .map { |timezone| Timezones::CleanerService.new(timezone).call }
      end

      it do
        ios_timezones.each do |timezone|
          expect(timezone_bearer_class.new(timezone)).to be_valid
        end
      end
    end

    context "with Android timezones" do
      let(:android_timezones) do
        CSV.read(Rails.root.join("spec/fixtures/files/timezones/android.csv"))
          .map(&:first)
          .map { |timezone| Timezones::CleanerService.new(timezone).call }
      end

      it do
        android_timezones.each do |timezone|
          expect(timezone_bearer_class.new(timezone)).to be_valid
        end
      end
    end
  end

  context "when timezone is not valid" do
    context "when it contains uppercase chars" do
      let(:instance) { timezone_bearer_class.new("abc/def") }

      it do
        expect(instance).not_to be_valid
        expect(instance.errors.full_messages).to include("Timezone must be a valid time zone")
      end
    end
  end
end
