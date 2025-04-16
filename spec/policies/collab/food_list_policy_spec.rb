# frozen_string_literal: true

require "rails_helper"

describe(Collab::FoodListPolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:editable_food_list) { create(:food_list, :editable) }
  let!(:non_editable_food_list) { create(:food_list) }

  permissions :index?, :show? do
    it do
      expect(described_class).to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).to permit(collaborator, editable_food_list)
      expect(described_class).to permit(collaborator_admin, editable_food_list)
      expect(described_class).to permit(collaborator, non_editable_food_list)
      expect(described_class).to permit(collaborator_admin, non_editable_food_list)
    end
  end

  permissions :edit?, :update? do
    it do
      expect(described_class).to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator, editable_food_list)
      expect(described_class).to permit(collaborator_admin, editable_food_list)
      expect(described_class).not_to permit(collaborator, non_editable_food_list)
      expect(described_class).not_to permit(collaborator_admin, non_editable_food_list)
    end
  end

  permissions :destroy? do
    let(:food_list_with_foods) { create(:food_list, :with_foods) }

    it do
      expect(described_class).not_to permit(collaborator, editable_food_list)
      expect(described_class).to permit(collaborator_admin, editable_food_list)
      expect(described_class).not_to permit(collaborator, food_list_with_foods)
      expect(described_class).not_to permit(collaborator_admin, food_list_with_foods)
      expect(described_class).not_to permit(collaborator, non_editable_food_list)
      expect(described_class).not_to permit(collaborator_admin, non_editable_food_list)
    end
  end

  describe "#permitted_attributes" do
    context "when persisted" do
      it do
        expect(described_class.new(collaborator, editable_food_list).permitted_attributes)
          .to be_empty
        expect(described_class.new(collaborator_admin, editable_food_list).permitted_attributes)
          .to contain_exactly(:country_id, :editable, :metadata_data, :name, :source, :version)
      end
    end

    context "when new record" do
      let!(:food_list) { build(:food_list) }

      it do
        expect(described_class.new(collaborator, editable_food_list).permitted_attributes)
          .to be_empty
        expect(described_class.new(collaborator_admin, editable_food_list).permitted_attributes)
          .to contain_exactly(:country_id, :editable, :metadata_data, :name, :source, :version)
      end
    end
  end

  describe "#permitted_sort_attributes" do
    let(:food_list) { build(:food_list) }

    it do
      expect(described_class.new(collaborator, editable_food_list).permitted_sort_attributes)
        .to contain_exactly("country", "name")
    end
  end

  describe Collab::FoodListPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator, FoodList).resolve)
          .to be_empty
        expect(described_class.new(collaborator_admin, FoodList).resolve)
          .to contain_exactly(editable_food_list, non_editable_food_list)
      end

      context "when collaborator collaborates on a cohort using editable_food_list" do
        before do
          cohort = create(:cohort, food_lists: [non_editable_food_list])
          create(:collaboration, collaborator: collaborator, cohort: cohort, role: "manager")
        end

        it do
          expect(described_class.new(collaborator, FoodList).resolve)
            .to contain_exactly(non_editable_food_list)
        end
      end
    end
  end
end
