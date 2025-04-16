# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collaboration) do
  let(:collaboration) { build(:collaboration, :annotator) }

  describe "Associations" do
    it do
      expect(collaboration).to belong_to(:collaborator).inverse_of(:collaborations)
      expect(collaboration).to belong_to(:cohort).inverse_of(:collaborations)
    end
  end

  describe "Validations" do
    let!(:collaboration) { create(:collaboration, :annotator) }

    it do
      expect(collaboration).to be_valid
      expect(collaboration).to validate_uniqueness_of(:collaborator_id)
        .case_insensitive
        .scoped_to(:cohort_id)
        .with_message("is already in the cohort")
    end
  end

  describe "Scope" do
    describe ".active" do
      let!(:active_collaboration_1) { create(:collaboration, :annotator, deactivated_at: nil) }
      let!(:active_collaboration_2) { create(:collaboration, :annotator, deactivated_at: 1.day.from_now) }
      let!(:deactivated_collaboration_1) { create(:collaboration, :annotator, deactivated_at: 1.hour.ago) }

      it do
        expect(described_class.active).to contain_exactly(active_collaboration_1, active_collaboration_2)
      end
    end
  end

  describe "#deactivate", :freeze_time do
    it do
      expect { collaboration.deactivate }
        .to change(collaboration, :deactivated_at).from(nil).to(Time.current)
    end
  end

  describe "#reactivate", :freeze_time do
    before { collaboration.deactivate }

    it do
      expect { collaboration.reactivate }
        .to change(collaboration, :deactivated_at).from(Time.current).to(nil)
    end
  end

  describe "#deactivated?" do
    context "when deactivated_at is nil" do
      it { expect(collaboration).not_to be_deactivated }
    end

    context "when deactivated_at is set" do
      before { collaboration.deactivate }

      it { expect(collaboration).to be_deactivated }
    end
  end
end
