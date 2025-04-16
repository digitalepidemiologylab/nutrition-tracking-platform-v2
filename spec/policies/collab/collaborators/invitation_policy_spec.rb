# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborators::InvitationPolicy) do
  let!(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }

  permissions :new?, :create? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager, manager_cohort)
      expect(described_class).not_to permit(annotator, annotator_cohort)
    end
  end
end
