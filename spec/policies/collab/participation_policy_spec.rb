# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ParticipationPolicy) do
  let(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }
  let!(:manager_cohort_participation) { create(:participation, cohort: manager_cohort) }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }
  let!(:annotator_cohort_participation) { create(:participation, cohort: annotator_cohort) }

  let!(:participation) { create(:participation) }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  permissions :show? do
    context "when participation cohort is managed by collaborator" do
      it do
        expect(described_class).to permit(manager, manager_cohort_participation)
        expect(described_class).not_to permit(annotator, annotator_cohort_participation)
      end
    end

    context "when participation cohort is not managed by collaborator" do
      it do
        expect(described_class).to permit(admin, participation)
        expect(described_class).not_to permit(manager, participation)
        expect(described_class).not_to permit(annotator, participation)
      end
    end
  end

  permissions :new?, :edit?, :create?, :update?, :destroy? do
    context "when participation cohort is managed by collaborator" do
      it do
        expect(described_class).to permit(admin, build(:participation, cohort: manager_cohort))
        expect(described_class).to permit(manager, build(:participation, cohort: manager_cohort))
        expect(described_class).not_to permit(annotator, build(:participation, cohort: annotator_cohort))
      end
    end

    context "when participation cohort is not managed by collaborator" do
      it do
        expect(described_class).to permit(admin, build(:participation))
        expect(described_class).not_to permit(manager, build(:participation))
        expect(described_class).not_to permit(annotator, build(:participation))
      end
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, build(:participation)).permitted_attributes)
        .to contain_exactly(:ended_at)
    end
  end

  describe Collab::ParticipationPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(admin, Participation).resolve)
          .to contain_exactly(manager_cohort_participation, annotator_cohort_participation, participation)
        expect(described_class.new(manager, Participation).resolve).to contain_exactly(manager_cohort_participation)
        expect(described_class.new(annotator, Participation).resolve).to contain_exactly(annotator_cohort_participation)
      end
    end
  end
end
