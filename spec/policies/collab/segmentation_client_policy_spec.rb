# frozen_string_literal: true

require "rails_helper"

describe(Collab::SegmentationClientPolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:segmentation_client) { create(:segmentation_client) }

  permissions :index?, :show? do
    it do
      expect(described_class).to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).to permit(collaborator, segmentation_client)
      expect(described_class).to permit(collaborator_admin, segmentation_client)
    end
  end

  permissions :edit?, :update? do
    it do
      expect(described_class).not_to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator, segmentation_client)
      expect(described_class).to permit(collaborator_admin, segmentation_client)
    end
  end

  permissions :destroy? do
    let(:segmentation_client_with_cohorts) { create(:segmentation_client, :with_cohort) }

    it do
      expect(described_class).not_to permit(collaborator, segmentation_client)
      expect(described_class).to permit(collaborator_admin, segmentation_client)
      expect(described_class).not_to permit(collaborator, segmentation_client_with_cohorts)
      expect(described_class).not_to permit(collaborator_admin, segmentation_client_with_cohorts)
    end
  end

  describe Collab::SegmentationClientPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator, SegmentationClient).resolve)
          .to contain_exactly(segmentation_client)
        expect(described_class.new(collaborator_admin, SegmentationClient).resolve)
          .to contain_exactly(segmentation_client)
      end
    end
  end
end
