# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::BasePolicy) do
  describe "#initialize" do
    context "when user is nil" do
      it do
        expect { described_class.new(nil, ApplicationRecord) }
          .to raise_error(Pundit::NotAuthorizedError, "You need to sign in or sign up before continuing.")
      end
    end
  end

  describe Api::V2::BasePolicy::Scope do
    describe "#initialize" do
      context "when user is nil" do
        it do
          expect { described_class.new(nil, ApplicationRecord) }
            .to raise_error(Pundit::NotAuthorizedError, "You need to sign in or sign up before continuing.")
        end
      end
    end
  end
end
