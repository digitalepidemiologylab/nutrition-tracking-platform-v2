# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborations::DeactivationPolicy) do
  let(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }

  permissions :create?, :destroy? do
    context "when collaboration cohort is managed by collaborator" do
      it do
        expect(described_class).to permit(manager, build(:collaboration, cohort: manager_cohort))
        expect(described_class).not_to permit(annotator, build(:collaboration, cohort: annotator_cohort))
      end
    end

    context "when collaboration cohort is not managed by collaborator" do
      it do
        expect(described_class).to permit(admin, build(:collaboration))
        expect(described_class).not_to permit(manager, build(:collaboration))
        expect(described_class).not_to permit(annotator, build(:collaboration))
      end
    end
  end
end
