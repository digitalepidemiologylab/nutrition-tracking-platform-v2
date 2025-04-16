# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::Participations::ParticipatePolicy) do
  let(:user) { create(:user) }

  permissions :create? do
    context "when associated_at is not nil" do
      let(:participation) { create(:participation, user: user) }

      it { expect(described_class).not_to permit(user, participation) }
    end

    context "when associated_at is nil" do
      let(:participation) { create(:participation, :nil_associated_at, user: participation_user) }

      context "when user is nil" do
        let(:participation_user) { nil }

        it { expect(described_class).to permit(user, participation) }
      end

      context "when user is user" do
        let(:participation_user) { user }

        it { expect(described_class).to permit(user, participation) }
      end

      context "when user is another user" do
        let(:participation_user) { create(:user) }

        it { expect(described_class).not_to permit(user, participation) }
      end
    end
  end
end
