# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodPolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:editable_food) { create(:food, :editable) }
  let(:non_editable_food_list) { create(:food_list, editable: false) }
  let(:non_editable_food) { create(:food) }

  permissions :index?, :show? do
    it do
      expect(described_class).to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).to permit(collaborator, editable_food)
      expect(described_class).to permit(collaborator_admin, editable_food)
    end
  end

  permissions :new?, :create?, :edit?, :update? do
    it do
      expect(described_class).not_to permit(collaborator)
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator, editable_food)
      expect(described_class).to permit(collaborator_admin, editable_food)
      expect(described_class).not_to permit(collaborator, non_editable_food)
      expect(described_class).not_to permit(collaborator_admin, non_editable_food)
    end
  end

  permissions :destroy? do
    let(:annotation_item) { create(:annotation_item) }
    let!(:food_with_annotation_items) { annotation_item.food }

    it do
      expect(described_class).not_to permit(collaborator, editable_food)
      expect(described_class).not_to permit(collaborator, non_editable_food)
      expect(described_class).not_to permit(collaborator, food_with_annotation_items)
      expect(described_class).to permit(collaborator_admin, editable_food)
      expect(described_class).not_to permit(collaborator_admin, non_editable_food)
      expect(described_class).not_to permit(collaborator_admin, food_with_annotation_items)
    end
  end

  describe "#permitted_attributes" do
    context "when persisted" do
      it do
        expect(described_class.new(collaborator, editable_food).permitted_attributes)
          .to contain_exactly(:annotatable, :portion_quantity, :fa_ps_ratio, :food_list_id, {food_set_ids: []},
            :kcal_max, :kcal_min, :segmentable, :unit_id, :name_de, :name_en, :name_fr,
            {food_nutrients_attributes: [:id, :nutrient_id, :per_hundred, :_destroy]})
        expect(described_class.new(collaborator_admin, editable_food).permitted_attributes)
          .to contain_exactly(:annotatable, :portion_quantity, :fa_ps_ratio, :food_list_id, {food_set_ids: []},
            :kcal_max, :kcal_min, :segmentable, :unit_id, :name_de, :name_en, :name_fr,
            {food_nutrients_attributes: [:id, :nutrient_id, :per_hundred, :_destroy]})
      end
    end

    context "when new record" do
      let!(:food) { build(:food) }

      it do
        expect(described_class.new(collaborator, editable_food).permitted_attributes)
          .to contain_exactly(:annotatable, :portion_quantity, :fa_ps_ratio, :food_list_id, {food_set_ids: []},
            :kcal_max, :kcal_min, :segmentable, :unit_id, :name_de, :name_en, :name_fr,
            {food_nutrients_attributes: [:id, :nutrient_id, :per_hundred, :_destroy]})
        expect(described_class.new(collaborator_admin, editable_food).permitted_attributes)
          .to contain_exactly(:annotatable, :portion_quantity, :fa_ps_ratio, :food_list_id, {food_set_ids: []},
            :kcal_max, :kcal_min, :segmentable, :unit_id, :name_de, :name_en, :name_fr,
            {food_nutrients_attributes: [:id, :nutrient_id, :per_hundred, :_destroy]})
      end
    end
  end

  describe "#permitted_sort_attributes" do
    let(:food) { build(:food) }

    it do
      expect(described_class.new(collaborator, editable_food).permitted_sort_attributes)
        .to contain_exactly("annotatable", "fa_ps_ratio", "food_list", "kcal_max", "kcal_min", "name", "segmentable", "unit_id")
    end
  end

  describe Collab::FoodPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(collaborator, Food).resolve)
          .to contain_exactly(editable_food)
        expect(described_class.new(collaborator_admin, Food).resolve)
          .to contain_exactly(editable_food)
      end
    end
  end
end
