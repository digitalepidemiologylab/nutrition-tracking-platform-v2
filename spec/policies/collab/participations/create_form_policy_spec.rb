# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Participations::CreateFormPolicy) do
  let!(:cohort) { create(:cohort) }
  let(:admin) { create(:collaborator, :admin) }
  let!(:collaboration_manager) { create(:collaboration, :manager, cohort: cohort) }
  let(:manager) { collaboration_manager.collaborator }
  let!(:collaboration_annotator) { create(:collaboration, :annotator, cohort: cohort) }
  let(:annotator) { collaboration_annotator.collaborator }

  let(:create_form) { Participations::CreateForm.new(cohort: cohort) }

  permissions :create? do
    it do
      expect(described_class).to permit(admin, create_form)
      expect(described_class).to permit(manager, create_form)
      expect(described_class).not_to permit(annotator, create_form)
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, cohort).permitted_attributes).to eq(:number)
    end
  end
end
