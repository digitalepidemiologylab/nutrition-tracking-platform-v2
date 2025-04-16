# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Participation) do
  describe "Associations" do
    let(:participation) { build(:participation) }

    it do
      expect(participation).to belong_to(:cohort).inverse_of(:participations)
      expect(participation).to belong_to(:user).inverse_of(:participations).optional
      expect(participation).to have_many(:annotations).inverse_of(:participation).dependent(:destroy)
      expect(participation).to have_many(:intakes).through(:annotations)
    end
  end

  describe "Scopes" do
    describe ".overlapped_by(participation)", :freeze_time do
      let!(:existing_participation) { create(:participation, started_at: 4.days.ago, ended_at: 2.days.ago) }
      let(:participation) { build(:participation, :not_associated, started_at: started_at, ended_at: ended_at) }

      describe "when not overlapping" do
        let(:started_at) { 6.days.ago }
        let(:ended_at) { 5.days.ago }

        it { expect(described_class.overlapped_by(participation)).to be_empty }
      end

      describe "when started_at is nil and ended_at before existing participation" do
        let(:started_at) { nil }
        let(:ended_at) { 5.days.ago }

        it { expect(described_class.overlapped_by(participation)).to be_empty }
      end

      describe "when started_at is nil and ended_at in existing participation" do
        let(:started_at) { nil }
        let(:ended_at) { 3.days.ago }

        it do
          expect(described_class.overlapped_by(participation)).to contain_exactly(existing_participation)
        end
      end

      describe "when started_at between existing participations started_at and ended_at" do
        let(:started_at) { 3.days.ago }
        let(:ended_at) { 1.day.ago }

        it do
          expect(described_class.overlapped_by(participation)).to contain_exactly(existing_participation)
        end
      end

      describe "when ended_at between existing participations started_at and ended_at" do
        let(:started_at) { 5.days.ago }
        let(:ended_at) { 2.days.ago }

        it do
          expect(described_class.overlapped_by(participation)).to contain_exactly(existing_participation)
        end
      end

      describe "when ended_at is nil and started_at before existing participations started_at and ended_at" do
        let(:started_at) { 5.days.ago }
        let(:ended_at) { nil }

        it do
          expect(described_class.overlapped_by(participation)).to contain_exactly(existing_participation)
        end
      end

      describe "when started_at is before existing participations started_at and ended_at after existing participations started_at" do
        let(:started_at) { 5.days.ago }
        let(:ended_at) { 1.day.ago }

        it do
          expect(described_class.overlapped_by(participation)).to contain_exactly(existing_participation)
        end
      end
    end
  end

  describe "Callbacks" do
    describe "after_initialize" do
      describe "#set_key" do
        it { expect(build(:participation).key).not_to be_blank }
      end
    end

    describe "before_save" do
      describe "#set_associated_at", :freeze_time do
        let!(:participation) { create(:participation, :not_associated, associated_at: nil) }

        before do
          allow(participation).to receive(:set_associated_at)
        end

        context "when user_id changes" do
          before do
            participation.user = create(:user)
          end

          it do
            participation.save
            expect(participation).to have_received(:set_associated_at)
          end
        end

        context "when user_id doesn't change" do
          it do
            participation.save
            expect(participation).not_to have_received(:set_associated_at)
          end
        end
      end
    end
  end

  describe "Validations" do
    describe "key" do
      let!(:participation) { build(:participation) }

      it { expect(participation).to validate_presence_of(:key) }
    end

    describe "user_id" do
      let!(:participation_1) { create(:participation) }
      let!(:participation_2) { build(:participation, user: participation_1.user, cohort: participation_1.cohort) }

      it do
        expect(participation_2).not_to be_valid
        expect(participation_2.errors.full_messages).to include("User ID has already been taken")
      end
    end

    describe "#not_overlapping_other_participations", :freeze_time do
      let(:user) { create(:user) }
      let(:existing_participation) { create(:participation, user: user) }
      let(:participation) { build(:participation, user: user) }

      describe "when no ovelapped participations" do
        before do
          allow(described_class).to receive(:overlapped_by).and_return([])
        end

        it { expect(participation).to be_valid }
      end

      describe "when ovelapped participations exists" do
        before do
          allow(described_class).to receive(:overlapped_by).and_return([existing_participation])
        end

        it do
          expect(participation).not_to be_valid
          expect(participation.errors.full_messages).to contain_exactly("Cannot overlap with another participation")
        end
      end
    end

    describe "#overlapping_intakes", :freeze_time do
      let(:intake_1) { build(:intake, consumed_at: 5.days.ago, annotation: nil) }
      let(:intake_2) { build(:intake, consumed_at: 2.days.ago, annotation: nil) }
      let(:annotation) { build(:annotation, intakes: [intake_1, intake_2], participation: nil) }
      let!(:participation) { create(:participation, started_at: 6.days.ago, ended_at: 1.day.ago, annotations: [annotation]) }

      context "when participation covers intakes" do
        it { expect(participation).to be_valid }
      end

      context "when started_at is after the first intake" do
        before { participation.started_at = 4.days.ago }

        it do
          expect(participation).not_to be_valid
          expect(participation.errors.full_messages).to contain_exactly("Participation start and end dates must include all intakes")
        end
      end

      context "when ended_at is before the first intake" do
        before { participation.ended_at = 3.days.ago }

        it do
          expect(participation).not_to be_valid
          expect(participation.errors.full_messages).to contain_exactly("Participation start and end dates must include all intakes")
        end
      end
    end
  end

  describe "#set_associated_at", :freeze_time do
    let(:participation) { build(:participation, associated_at: nil, started_at: started_at) }

    context "when started_at is blank" do
      let(:started_at) { nil }

      it do
        expect { participation.set_associated_at }
          .to change(participation, :associated_at).from(nil).to(Time.current)
          .and(change(participation, :started_at).from(nil).to(Time.current))
      end
    end

    context "when started_at is set" do
      let(:started_at) { 1.day.ago }

      it do
        expect { participation.set_associated_at }
          .to change(participation, :associated_at).from(nil).to(Time.current)
          .and(not_change(participation, :started_at).from(started_at))
      end
    end
  end
end
