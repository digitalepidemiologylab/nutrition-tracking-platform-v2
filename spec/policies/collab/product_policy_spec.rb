# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ProductPolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:product) { create(:product) }

  permissions :index?, :show? do
    it do
      expect(described_class).to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).to permit(collaborator, product)
      expect(described_class).to permit(collaborator_admin, product)
    end
  end

  describe "#permitted_sort_attributes" do
    let(:product) { build(:product) }

    it do
      expect(described_class.new(collaborator, product).permitted_sort_attributes)
        .to contain_exactly("barcode", "name", "source", "status", "unit_id", "fetched_at")
    end
  end

  describe described_class::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator, Product).resolve)
          .to contain_exactly(product)
        expect(described_class.new(collaborator_admin, Product).resolve)
          .to contain_exactly(product)
      end
    end
  end
end
