# frozen_string_literal: true

require "rails_helper"

describe(Intake) do
  it_behaves_like "has_timezone"

  describe "Associations" do
    let(:intake) { build(:intake) }

    it { expect(intake).to belong_to(:annotation).inverse_of(:intakes) }

    # It has paper_trail
    it { expect(intake).to be_versioned }
  end

  describe "Validations" do
    let(:intake) { build(:intake, annotation: create(:annotation, participation: create(:participation, started_at: 1.day.ago))) }

    it { expect(intake).to be_valid }

    describe "id" do
      it { expect(intake).to validate_uniqueness_of(:id).case_insensitive }
    end

    describe "consumed_at" do
      it { expect(intake).to validate_presence_of(:consumed_at) }

      describe "when in the past" do
        before { intake.consumed_at = 30.minutes.ago }

        it { expect(intake).to be_valid }
      end

      describe "when less than 1 hour from now" do
        before { intake.consumed_at = 30.minutes.from_now }

        it { expect(intake).to be_valid }
      end

      describe "when more than 1 hour from now" do
        before { intake.consumed_at = 2.hours.from_now }

        it do
          expect(intake).not_to be_valid
          expect(intake.errors[:consumed_at]).to include("must be less than or equal to 1 hour from now")
        end
      end
    end

    describe "#consumed_at_during_participation" do
      let(:participation) { create(:participation, started_at: started_at, ended_at: ended_at) }
      let(:annotation) { create(:annotation, participation: participation) }
      let(:intake) { build(:intake, annotation: annotation, consumed_at: consumed_at) }

      context "when consumed_at is during participation" do
        let(:started_at) { 1.day.ago }
        let(:ended_at) { nil }
        let(:consumed_at) { 1.hour.ago }

        it { expect(intake).to be_valid }
      end

      context "when consumed_at is before participation started_at" do
        let(:started_at) { 1.day.ago }
        let(:ended_at) { nil }
        let(:consumed_at) { 2.days.ago }

        it do
          expect(intake).not_to be_valid
          expect(intake.errors[:consumed_at]).to include("must be during user participation")
        end
      end

      context "when consumed_at is after participation ended_at" do
        let(:started_at) { 1.day.ago }
        let(:ended_at) { nil }
        let(:consumed_at) { 1.day.from_now }

        it do
          expect(intake).not_to be_valid
          expect(intake.errors[:consumed_at]).to include("must be during user participation")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "after_destroy_commit" do
      describe "destroy_annotation_if_no_intakes" do
        context "when annotation has no more intake" do
          let!(:annotation) { create(:annotation) }

          it do
            expect { annotation.intakes.sole.destroy }
              .to change(Annotation, :count).by(-1)
            expect(annotation).to be_destroyed
          end
        end

        context "when annotation has many intakes" do
          let!(:annotation) { create(:annotation, :with_intakes) }

          it do
            expect { annotation.intakes.first.destroy }
              .to not_change(Annotation, :count)
            expect(annotation).not_to be_destroyed
            expect(annotation.reload.intakes.count).to eq(1)
          end
        end

        context "when annotation has one intake, that has a comment associated with push notifications" do
          let!(:push_notification) { create(:push_notification) }
          let(:comment) { push_notification.comment }
          let!(:annotation) { comment.annotation }
          let(:intake) { annotation.intakes.sole }

          it do
            expect { intake.destroy }
              .to change(Annotation, :count).by(-1)
              .and(change(Comment, :count).by(-1))
              .and(change(PushNotification, :count).by(-1))
          end
        end
      end
    end
  end

  describe "Versioning" do
    with_versioning do
      it do
        PaperTrail.request(whodunnit: "John Doe") do
          intake = create(:intake)
          expect { intake.destroy }
            .to change(described_class, :count).by(-1)
            .and(change { intake.versions.count }.by(1))
        end
      end
    end
  end
end
