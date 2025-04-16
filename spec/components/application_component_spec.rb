# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ApplicationComponent) do
  describe "Validations" do
    describe "#validate_inclusion_of(attr, value:, accepted_values:)" do
      let(:instance) { described_class.new }

      context "when valid" do
        it do
          expect { instance.validate_inclusion_of(:type, value: :button, accepted_values: %i[button submit]) }
            .not_to raise_error
        end
      end

      context "when invalid" do
        it do
          expect { instance.validate_inclusion_of(:type, value: :button, accepted_values: %i[reset submit]) }
            .to raise_error(ApplicationComponent::InvalidArgumentError, "Type argument must be in reset, submit")
        end
      end
    end
  end
end
