# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::CohortPolicy) do
  let(:admin) { create(:collaborator, :admin) }
  let!(:collaboration_manager) { create(:collaboration, :manager) }
  let(:manager) { collaboration_manager.collaborator }
  let!(:collaboration_annotator) { create(:collaboration, :annotator) }
  let(:annotator) { collaboration_annotator.collaborator }
  let!(:cohort) { create(:cohort) }

  permissions :show? do
    context "when managed by collaborator" do
      it do
        expect(described_class).to permit(manager, collaboration_manager.cohort)
        expect(described_class).not_to permit(annotator, collaboration_annotator.cohort)
      end
    end

    context "when not managed by collaborator" do
      it do
        expect(described_class).to permit(admin, cohort)
        expect(described_class).not_to permit(manager, cohort)
        expect(described_class).not_to permit(annotator, cohort)
      end
    end
  end

  describe "#permitted_includes" do
    it do
      expect(described_class.new(manager, cohort).permitted_includes).to contain_exactly("food_lists")
    end
  end
end
