# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::BasePolicy) do
  describe "#initialize" do
    context "when collaborator is nil" do
      it do
        expect { described_class.new(nil, ApplicationRecord) }
          .to raise_error(Pundit::NotAuthorizedError, "You need to sign in or sign up before continuing.")
      end
    end

    describe "#manager?" do
      let(:cohort) { build(:cohort) }

      context "when collaborator is not manager" do
        let(:collaborator) { create(:collaborator) }

        it do
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_manager(cohort: :any)
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_manager(cohort: cohort)
        end
      end

      context "when collaborator is manager" do
        let(:collaboration_manager) { create(:collaboration, :manager) }
        let(:manager) { collaboration_manager.collaborator }

        it do
          expect(described_class.new(manager, ApplicationRecord)).to be_manager(cohort: :any)
          expect(described_class.new(manager, ApplicationRecord)).to be_manager(cohort: collaboration_manager.cohort)
          expect(described_class.new(manager, ApplicationRecord)).not_to be_manager(cohort: cohort)
        end
      end
    end

    describe "#annotator?" do
      let(:cohort) { build(:cohort) }

      context "when collaborator is not annotator" do
        let(:collaborator) { create(:collaborator) }

        it do
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_annotator(cohort: :any)
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_annotator(cohort: cohort)
        end
      end

      context "when collaborator is annotator" do
        let(:collaboration_annotator) { create(:collaboration, :annotator) }
        let(:annotator) { collaboration_annotator.collaborator }

        it do
          expect(described_class.new(annotator, ApplicationRecord)).to be_annotator(cohort: :any)
          expect(described_class.new(annotator, ApplicationRecord))
            .to be_annotator(cohort: collaboration_annotator.cohort)
          expect(described_class.new(annotator, ApplicationRecord)).not_to be_annotator(cohort: cohort)
        end
      end
    end

    describe "#manager_or_annotator?" do
      let(:cohort) { build(:cohort) }

      context "when collaborator is not is not a manager or annotator" do
        let(:collaborator) { create(:collaborator) }

        it do
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_manager_or_annotator(cohort: :any)
          expect(described_class.new(collaborator, ApplicationRecord)).not_to be_manager_or_annotator(cohort: cohort)
        end
      end

      context "when collaborator is manager" do
        let(:collaboration_manager) { create(:collaboration, :manager) }
        let(:manager) { collaboration_manager.collaborator }

        it do
          expect(described_class.new(manager, ApplicationRecord)).to be_manager_or_annotator(cohort: :any)
          expect(described_class.new(manager, ApplicationRecord))
            .to be_manager_or_annotator(cohort: collaboration_manager.cohort)
          expect(described_class.new(manager, ApplicationRecord)).not_to be_manager_or_annotator(cohort: cohort)
        end
      end

      context "when collaborator is annotator" do
        let(:collaboration_annotator) { create(:collaboration, :annotator) }
        let(:annotator) { collaboration_annotator.collaborator }

        it do
          expect(described_class.new(annotator, ApplicationRecord)).to be_manager_or_annotator(cohort: :any)
          expect(described_class.new(annotator, ApplicationRecord))
            .to be_manager_or_annotator(cohort: collaboration_annotator.cohort)
          expect(described_class.new(annotator, ApplicationRecord)).not_to be_manager_or_annotator(cohort: cohort)
        end
      end
    end
  end

  describe "#translated_attributes_for(attribute)" do
    let(:collaborator) { create(:collaborator) }

    it do
      expect(described_class.new(collaborator, ApplicationRecord).translated_attributes_for(:name))
        .to contain_exactly(:name_de, :name_en, :name_fr)
    end
  end

  describe Collab::BasePolicy::Scope do
    describe "#initialize" do
      context "when collaborator is nil" do
        it do
          expect { described_class.new(nil, ApplicationRecord) }
            .to raise_error(Pundit::NotAuthorizedError, "You need to sign in or sign up before continuing.")
        end
      end
    end
  end
end
