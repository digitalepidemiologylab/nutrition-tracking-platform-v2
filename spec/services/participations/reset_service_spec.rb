# frozen_string_literal: true

require "rails_helper"

describe Participations::ResetService do
  let(:user) { create(:user, :with_tokens) }
  let(:participation) { create(:participation, user: user) }
  let(:service) { described_class.new(participation: participation) }

  describe "#call" do
    context "when successful" do
      it do
        expect { service.call }
          .to change { participation.reload.associated_at }.to(nil)
          .and(change { user.reload.tokens }.to({}))
        expect(service.errors).to be_empty
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Participation)
          .to receive(:invalid?)
          .and_return(true)
        allow_any_instance_of(Participation)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(participation).tap { |e| e.add(:associated_at, "cannot be blank") })
      end

      it do
        expect { service.call }
          .to raise_error(
            ActiveModel::ValidationError,
            "Validation failed: Participation: associated_at cannot be blank"
          )
          .and(not_change { user.reload.tokens })
      end
    end
  end
end
