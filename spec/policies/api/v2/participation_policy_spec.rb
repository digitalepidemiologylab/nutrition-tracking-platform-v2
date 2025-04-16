# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::ParticipationPolicy) do
  let(:user) { create(:user) }

  permissions :index? do
    it { expect(described_class).to permit(user, Participation) }
  end

  describe "#permitted_attributes" do
    let!(:participation) { create(:participation) }

    it do
      expect(described_class.new(user, participation).permitted_attributes)
        .to contain_exactly(:key)
    end
  end

  describe "#permitted_includes" do
    let!(:participation) { create(:participation) }

    it do
      expect(described_class.new(user, participation).permitted_includes).to contain_exactly("cohort")
    end
  end

  describe Api::V2::ParticipationPolicy::Scope do
    let(:dish) { create(:dish, user: user) }
    let!(:participation) { create(:participation, user: user) }

    describe "#resolve" do
      context "when user has participations" do
        it { expect(described_class.new(user, Participation).resolve).to contain_exactly(participation) }
      end

      context "when user has no participations" do
        let(:user_without_participation) { create(:user) }

        it { expect(described_class.new(user_without_participation, Participation).resolve).to be_empty }
      end
    end
  end
end
