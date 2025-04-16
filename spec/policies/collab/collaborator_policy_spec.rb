# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CollaboratorPolicy) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:cohort) { create(:cohort) }
  let!(:manager_collaboration) { create(:collaboration, :manager, cohort: cohort) }
  let(:manager) { manager_collaboration.collaborator }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, cohort: cohort) }
  let!(:annotator) { annotator_collaboration.collaborator }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).not_to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, manager).permitted_attributes).to contain_exactly(:email, :name, :timezone)
    end
  end

  describe Collab::CollaboratorPolicy::Scope do
    let!(:collaborator) { create(:collaborator) }

    describe "#resolve" do
      it do
        expect(described_class.new(admin, Collaborator).resolve)
          .to contain_exactly(admin, manager, annotator, collaborator)
        expect(described_class.new(manager, Collaborator).resolve).to contain_exactly(manager, annotator)
        expect(described_class.new(annotator, Collaborator).resolve).to contain_exactly(annotator)
      end
    end
  end
end
