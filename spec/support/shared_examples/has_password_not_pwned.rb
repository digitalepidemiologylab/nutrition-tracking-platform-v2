# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples("has_password_not_pwned") do
  let(:base_factory) { described_class.name.underscore }

  describe "Validations" do
    describe "password" do
      describe "pwned" do
        let(:instance) { build(base_factory, password: "MyFoodRepoPassword") }
        let(:stub) { stub_request(:get, "https://api.pwnedpasswords.com/range/824E8") }

        context "with bypass_pwned_validation == false" do
          before { instance.validate }

          it do
            expect(stub).to have_been_requested
          end
        end

        context "with bypass_pwned_validation == true" do
          before do
            instance.bypass_pwned_validation = true
            instance.validate
          end

          it do
            expect(stub).not_to have_been_requested
          end
        end
      end
    end
  end
end
