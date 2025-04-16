# frozen_string_literal: true

require "rails_helper"

describe(Collab::Annotations::ConfirmationPolicy) do
  let!(:cohort_1) { create(:cohort) }
  let!(:cohort_2) { create(:cohort) }

  let!(:admin) { create(:collaborator, :admin) }

  let!(:manager_1) { create(:collaborator) }
  let!(:manager_1_collaboration) { create(:collaboration, :manager, collaborator: manager_1, cohort: cohort_1) }

  let!(:manager_2) { create(:collaborator) }
  let!(:manager_2_collaboration) { create(:collaboration, :manager, collaborator: manager_2, cohort: cohort_2) }

  let!(:annotator_1) { create(:collaborator) }
  let!(:annotator_1_collaboration) { create(:collaboration, :annotator, collaborator: annotator_1, cohort: cohort_1) }

  let!(:annotator_2) { create(:collaborator) }
  let!(:annotator_2_collaboration) { create(:collaboration, :annotator, :deactivated, collaborator: annotator_2, cohort: cohort_2) }

  let!(:participation_1) { create(:participation, cohort: cohort_1) }
  let!(:participation_1_annotation) { create(:annotation, participation: participation_1) }

  let!(:participation_2) { create(:participation, cohort: cohort_2) }
  let!(:participation_2_annotation) { create(:annotation, participation: participation_2) }

  permissions :create? do
    it do
      expect(described_class).to permit(admin, participation_1_annotation)
      expect(described_class).to permit(admin, participation_2_annotation)

      expect(described_class).to permit(manager_1, participation_1_annotation)
      expect(described_class).not_to permit(manager_1, participation_2_annotation)

      expect(described_class).not_to permit(manager_2, participation_1_annotation)
      expect(described_class).to permit(manager_2, participation_2_annotation)

      expect(described_class).to permit(annotator_1, participation_1_annotation)
      expect(described_class).not_to permit(annotator_1, participation_2_annotation)

      expect(described_class).not_to permit(annotator_2, participation_1_annotation)
      expect(described_class).to permit(annotator_2, participation_2_annotation)
    end
  end
end
