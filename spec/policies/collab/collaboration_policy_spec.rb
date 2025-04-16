# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CollaborationPolicy) do
  let(:admin) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }

  let(:manager_1) { create(:collaborator) }
  let!(:manager_1_collaboration) { create(:collaboration, :manager, collaborator: manager_1, cohort: cohort) }

  let(:manager_2) { create(:collaborator) }
  let!(:manager_2_collaboration) { create(:collaboration, :manager, :deactivated, collaborator: manager_2, cohort: cohort) }

  let(:annotator_1) { create(:collaborator) }
  let!(:annotator_1_collaboration_1) { create(:collaboration, :annotator, collaborator: annotator_1, cohort: cohort) }
  let!(:annotator_1_collaboration_2) { create(:collaboration, :annotator, collaborator: annotator_1) }

  let(:annotator_2) { create(:collaborator) }
  let!(:annotator_2_collaboration_1) { create(:collaboration, :annotator, :deactivated, collaborator: annotator_2, cohort: cohort) }

  let!(:collaboration) { create(:collaboration, :manager) }

  permissions :edit?, :update? do
    context "when admin" do
      it do
        expect(described_class).to permit(admin, manager_1_collaboration)
        expect(described_class).to permit(admin, manager_2_collaboration)
        expect(described_class).to permit(admin, annotator_1_collaboration_1)
        expect(described_class).to permit(admin, annotator_1_collaboration_2)
        expect(described_class).to permit(admin, annotator_2_collaboration_1)
        expect(described_class).to permit(admin, collaboration)
      end
    end

    context "when manager_1" do
      it do
        expect(described_class).to permit(manager_1, manager_1_collaboration)
        expect(described_class).to permit(manager_1, manager_2_collaboration)
        expect(described_class).to permit(manager_1, annotator_1_collaboration_1)
        expect(described_class).not_to permit(manager_1, annotator_1_collaboration_2)
        expect(described_class).to permit(manager_1, annotator_2_collaboration_1)
        expect(described_class).not_to permit(manager_1, collaboration)
      end
    end

    context "when manager_2" do
      it do
        expect(described_class).to permit(manager_2, manager_1_collaboration)
        expect(described_class).to permit(manager_2, manager_2_collaboration)
        expect(described_class).to permit(manager_2, annotator_1_collaboration_1)
        expect(described_class).not_to permit(manager_2, annotator_1_collaboration_2)
        expect(described_class).to permit(manager_2, annotator_2_collaboration_1)
        expect(described_class).not_to permit(manager_2, collaboration)
      end
    end

    context "when annotator_1" do
      it do
        expect(described_class).not_to permit(annotator_1, manager_1_collaboration)
        expect(described_class).not_to permit(annotator_1, manager_2_collaboration)
        expect(described_class).not_to permit(annotator_1, annotator_1_collaboration_1)
        expect(described_class).not_to permit(annotator_1, annotator_1_collaboration_2)
        expect(described_class).not_to permit(annotator_1, annotator_2_collaboration_1)
        expect(described_class).not_to permit(annotator_1, collaboration)
      end
    end

    context "when annotator_2" do
      it do
        expect(described_class).not_to permit(annotator_2, manager_1_collaboration)
        expect(described_class).not_to permit(annotator_2, manager_2_collaboration)
        expect(described_class).not_to permit(annotator_2, annotator_1_collaboration_1)
        expect(described_class).not_to permit(annotator_2, annotator_1_collaboration_2)
        expect(described_class).not_to permit(annotator_2, annotator_2_collaboration_1)
        expect(described_class).not_to permit(annotator_2, collaboration)
      end
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, collaboration).permitted_attributes).to contain_exactly(:role)
    end
  end

  describe Collab::CollaborationPolicy::Scope do
    describe "#resolve" do
      context "when admin" do
        it do
          expect(described_class.new(admin, Collaboration).resolve)
            .to contain_exactly(
              manager_1_collaboration, manager_2_collaboration, annotator_1_collaboration_1, annotator_1_collaboration_2, annotator_2_collaboration_1, collaboration
            )
        end
      end

      context "when manager_1" do
        it do
          expect(described_class.new(manager_1, Collaboration).resolve)
            .to contain_exactly(
              manager_1_collaboration, manager_2_collaboration, annotator_1_collaboration_1, annotator_2_collaboration_1
            )
        end
      end

      context "when manager_2" do
        it do
          expect(described_class.new(manager_2, Collaboration).resolve)
            .to contain_exactly(
              manager_1_collaboration, manager_2_collaboration, annotator_1_collaboration_1, annotator_2_collaboration_1
            )
        end
      end

      context "when annotator_1" do
        it do
          expect(described_class.new(annotator_1, Collaboration).resolve)
            .to contain_exactly(annotator_1_collaboration_1, annotator_1_collaboration_2)
        end
      end

      context "when annotator_2" do
        it do
          expect(described_class.new(annotator_2, Collaboration).resolve)
            .to be_empty
        end
      end
    end
  end
end
