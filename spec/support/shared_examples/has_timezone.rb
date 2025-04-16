# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples("has_timezone") do
  let(:base_factory) { described_class.name.underscore }
  let(:instance) { build(base_factory) }

  describe "Validations" do
    describe "timezone" do
      describe "presence" do
        it { expect(instance).to validate_presence_of(:timezone) }
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      describe "#clean_timezone" do
        let(:cleaner_service) { instance_double(Timezones::CleanerService) }

        before do
          allow(Timezones::CleanerService).to receive(:new).and_return(cleaner_service)
          allow(cleaner_service).to receive(:call).with(no_args).and_return(instance.timezone)
        end

        it do
          instance.validate
          expect(Timezones::CleanerService).to have_received(:new).with(instance.timezone).once
          expect(cleaner_service).to have_received(:call).once
        end
      end
    end
  end
end
