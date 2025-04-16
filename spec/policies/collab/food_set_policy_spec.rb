# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodSetPolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:food_set) { create(:food_set) }

  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it do
      expect(described_class).not_to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator, food_set)
      expect(described_class).to permit(collaborator_admin, food_set)
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(collaborator, food_set).permitted_attributes)
        .to contain_exactly(:cname, :name_de, :name_en, :name_fr)
      expect(described_class.new(collaborator_admin, food_set).permitted_attributes)
        .to contain_exactly(:cname, :name_de, :name_en, :name_fr)
    end
  end

  describe Collab::FoodSetPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator, FoodSet).resolve)
          .to contain_exactly(food_set)
        expect(described_class.new(collaborator_admin, FoodSet).resolve)
          .to contain_exactly(food_set)
      end
    end
  end
end
