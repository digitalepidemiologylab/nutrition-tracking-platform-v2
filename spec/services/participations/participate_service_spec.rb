# frozen_string_literal: true

require "rails_helper"

describe Participations::ParticipateService, :freeze_time do
  let!(:user) { create(:user) }
  let!(:participation) { create(:participation, :not_associated) }
  let!(:service) { described_class.new(participation: participation, user: user) }

  describe "#call" do
    context "when successful" do
      it do
        expect { service.call }
          .to change { participation.reload.user }.from(nil).to(user)
          .and(change { participation.reload.associated_at }.from(nil).to(Time.current))
        expect(service.errors).to be_empty
      end
    end

    context "when participation is not available for user" do
      let(:policy) { instance_double(Api::V2::Participations::ParticipatePolicy) }

      before do
        allow(Api::V2::Participations::ParticipatePolicy)
          .to receive(:new).and_return(policy)
        allow(policy).to receive(:create?).and_return(false)
      end

      it do
        expect { service.call }
          .to raise_error(ActiveModel::ValidationError, "Validation failed: Key is not available")
          .and(not_change { participation.reload.associated_at }.from(nil))
      end
    end

    context "when participation is invalid" do
      before do
        allow_any_instance_of(Participation)
          .to receive(:invalid?)
          .and_return(true)
        allow_any_instance_of(Participation)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(participation).tap { |e| e.add(:key, "not available") })
      end

      it do
        expect { service.call }
          .to raise_error(ActiveModel::ValidationError, "Validation failed: Participation: key not available")
          .and(not_change { participation.reload.associated_at }.from(nil))
      end
    end
  end
end
