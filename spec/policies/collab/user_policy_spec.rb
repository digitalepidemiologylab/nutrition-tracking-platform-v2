# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::UserPolicy) do
  let(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }
  let!(:manager_cohort_participation) { create(:participation, cohort: manager_cohort) }
  let!(:manager_cohort_participation_user) { manager_cohort_participation.user }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }
  let!(:annotator_cohort_participation) { create(:participation, cohort: annotator_cohort) }
  let!(:annotator_cohort_participation_user) { annotator_cohort_participation.user }

  let!(:participation) { create(:participation) }
  let!(:participation_user) { participation.user }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  permissions :show? do
    it do
      expect(described_class).to permit(admin, manager_cohort_participation_user)
      expect(described_class).to permit(admin, annotator_cohort_participation_user)
      expect(described_class).to permit(admin, participation_user)
      expect(described_class).to permit(manager, manager_cohort_participation_user)
      expect(described_class).not_to permit(manager, annotator_cohort_participation_user)
      expect(described_class).not_to permit(manager, participation_user)
      expect(described_class).not_to permit(annotator, manager_cohort_participation_user)
      expect(described_class).not_to permit(annotator, annotator_cohort_participation_user)
      expect(described_class).not_to permit(annotator, participation_user)
    end
  end

  permissions :destroy? do
    it do
      expect(described_class).to permit(admin, manager_cohort_participation_user)
      expect(described_class).to permit(admin, annotator_cohort_participation_user)
      expect(described_class).to permit(admin, participation_user)
      expect(described_class).not_to permit(manager, manager_cohort_participation_user)
      expect(described_class).not_to permit(manager, annotator_cohort_participation_user)
      expect(described_class).not_to permit(manager, participation_user)
      expect(described_class).not_to permit(annotator, manager_cohort_participation_user)
      expect(described_class).not_to permit(annotator, annotator_cohort_participation_user)
      expect(described_class).not_to permit(annotator, participation_user)
    end
  end

  describe "#permitted_sort_attributes" do
    it do
      expect(described_class.new(admin, participation_user).permitted_sort_attributes)
        .to contain_exactly("email", "created_at")
    end
  end

  describe Collab::UserPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(admin, User).resolve)
          .to contain_exactly(manager_cohort_participation_user, annotator_cohort_participation_user, participation_user)
        expect(described_class.new(manager, User).resolve).to contain_exactly(manager_cohort_participation_user)
        expect(described_class.new(annotator, User).resolve).to contain_exactly(annotator_cohort_participation_user)
      end
    end
  end
end
