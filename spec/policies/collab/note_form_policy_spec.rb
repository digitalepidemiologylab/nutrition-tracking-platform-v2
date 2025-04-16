# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::NoteFormPolicy) do
  let(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }
  let!(:manager_cohort_participation) { create(:participation, cohort: manager_cohort) }
  let!(:manager_cohort_participation_user) { manager_cohort_participation.user }
  let!(:manager_cohort_participation_user_note_form) { NoteForm.new(notable: manager_cohort_participation_user) }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }
  let!(:annotator_cohort_participation) { create(:participation, cohort: annotator_cohort) }
  let!(:annotator_cohort_participation_user) { annotator_cohort_participation.user }
  let!(:annotator_cohort_participation_user_note_form) { NoteForm.new(notable: annotator_cohort_participation_user) }

  let!(:participation) { create(:participation) }
  let!(:participation_user) { participation.user }
  let!(:participation_user_note_form) { NoteForm.new(notable: participation_user) }

  permissions :show?, :edit?, :update? do
    it do
      expect(described_class).to permit(admin, manager_cohort_participation_user_note_form)
      expect(described_class).to permit(admin, annotator_cohort_participation_user_note_form)
      expect(described_class).to permit(admin, participation_user_note_form)
      expect(described_class).to permit(manager, manager_cohort_participation_user_note_form)
      expect(described_class).not_to permit(manager, annotator_cohort_participation_user_note_form)
      expect(described_class).not_to permit(manager, participation_user_note_form)
      expect(described_class).not_to permit(annotator, manager_cohort_participation_user_note_form)
      expect(described_class).to permit(annotator, annotator_cohort_participation_user_note_form)
      expect(described_class).not_to permit(annotator, participation_user_note_form)
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, participation_user).permitted_attributes)
        .to contain_exactly(:note)
    end
  end
end
