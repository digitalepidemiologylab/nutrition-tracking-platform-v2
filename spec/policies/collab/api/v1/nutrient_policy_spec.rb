# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::NutrientPolicy) do
  let!(:cohort) { create(:cohort) }
  let(:admin) { create(:collaborator, :admin) }
  let!(:collaboration_manager) { create(:collaboration, :manager, cohort: cohort) }
  let(:manager) { collaboration_manager.collaborator }
  let!(:collaboration_annotator) { create(:collaboration, :annotator, cohort: cohort) }
  let(:annotator) { collaboration_annotator.collaborator }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).to permit(annotator)
    end
  end

  describe Collab::Api::V1::NutrientPolicy::Scope do
    describe "#resolve" do
      let!(:nutrient) { create(:nutrient) }

      it do
        expect(described_class.new(admin, Nutrient).resolve).to contain_exactly(nutrient)
        expect(described_class.new(manager, Nutrient).resolve).to contain_exactly(nutrient)
        expect(described_class.new(annotator, Nutrient).resolve).to contain_exactly(nutrient)
      end
    end
  end
end
