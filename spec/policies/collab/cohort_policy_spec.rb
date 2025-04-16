# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CohortPolicy) do
  let(:admin) { create(:collaborator, :admin) }
  let!(:collaboration_manager) { create(:collaboration, :manager) }
  let(:manager) { collaboration_manager.collaborator }
  let!(:collaboration_annotator) { create(:collaboration, :annotator) }
  let(:annotator) { collaboration_annotator.collaborator }
  let!(:cohort) { create(:cohort) }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

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

  permissions :create? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).not_to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  permissions :update? do
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

  describe "#permitted_attributes" do
    context "when collaborator is manager" do
      it { expect(described_class.new(manager, cohort).permitted_attributes).to contain_exactly(:name, :segmentation_client_id, food_list_ids: []) }
    end

    context "when collaborator is admin" do
      it { expect(described_class.new(admin, cohort).permitted_attributes).to contain_exactly(:name, :segmentation_client_id, food_list_ids: []) }
    end
  end

  describe Collab::CohortPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(admin, Cohort).resolve)
          .to contain_exactly(collaboration_manager.cohort, collaboration_annotator.cohort, cohort)
        expect(described_class.new(manager, Cohort).resolve).to contain_exactly(collaboration_manager.cohort)
        expect(described_class.new(annotator, Cohort).resolve).to contain_exactly(collaboration_annotator.cohort)
      end
    end
  end
end
