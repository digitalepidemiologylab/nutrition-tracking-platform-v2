# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Participations::ResetterPolicy) do
  let(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_cohort) { manager_collaboration.cohort }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_cohort) { annotator_collaboration.cohort }

  let!(:participation) { create(:participation) }

  permissions :create? do
    context "when participation cohort is managed by collaborator" do
      it do
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
end
