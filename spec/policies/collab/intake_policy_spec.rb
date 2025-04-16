# frozen_string_literal: true

require "rails_helper"

describe(Collab::IntakePolicy) do
  let!(:admin) { create(:collaborator, :admin) }

  let!(:manager_collaboration) { create(:collaboration, :manager) }
  let!(:manager) { manager_collaboration.collaborator }
  let!(:manager_cohort) { manager_collaboration.cohort }
  let!(:manager_participation) { create(:participation, cohort: manager_cohort) }
  let!(:manager_user) { manager_participation.user }
  let!(:manager_dish) { create(:dish, user: manager_user) }
  let!(:manager_intake) { manager_dish.annotations.sole.intakes.sole }

  let!(:annotator_collaboration) { create(:collaboration, :annotator) }
  let!(:annotator) { annotator_collaboration.collaborator }
  let!(:annotator_cohort) { annotator_collaboration.cohort }
  let!(:annotator_participation) { create(:participation, cohort: annotator_cohort) }
  let!(:annotator_user) { annotator_participation.user }
  let!(:annotator_dish) { create(:dish, user: annotator_user) }
  let!(:annotator_intake) { annotator_dish.annotations.sole.intakes.sole }

  let!(:dish) { create(:dish) }
  let!(:intake) { dish.annotations.sole.intakes.sole }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  describe "#permitted_sort_attributes" do
    let(:intake) { build(:intake) }

    it do
      expect(described_class.new(admin, intake).permitted_sort_attributes)
        .to contain_exactly("annotations.status", "intakes.consumed_at")
    end
  end

  describe Collab::IntakePolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(admin, Intake).resolve)
          .to contain_exactly(manager_intake, annotator_intake, intake)
        expect(described_class.new(manager, Intake).resolve).to contain_exactly(manager_intake)
        expect(described_class.new(annotator, Intake).resolve).to contain_exactly(annotator_intake)
      end
    end
  end
end
