# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Food) do
  it_behaves_like "searchable_by_name"

  describe "Association" do
    let(:food) { build(:food) }

    it do
      expect(food).to belong_to(:food_list).inverse_of(:foods)
      expect(food).to belong_to(:unit).inverse_of(:foods)
      expect(food).to have_many(:food_food_sets).dependent(:destroy).inverse_of(:food)
      expect(food).to have_many(:food_sets).through(:food_food_sets)
      expect(food).to have_many(:annotation_items).inverse_of(:food).dependent(:restrict_with_error)
      expect(food).to have_many(:food_nutrients).inverse_of(:food).dependent(:destroy)
    end
  end

  describe "Translation" do
    let(:food) { build(:food) }

    it { expect(food).to translate(:name) }
  end

  describe "Validations" do
    describe "name" do
      describe "presence" do
        let!(:food) { build(:food) }

        it do
          expect(food).to validate_presence_of(:name_en)
          expect(food).not_to validate_presence_of(:name_fr)
          expect(food).not_to validate_presence_of(:name_de)
        end
      end

      describe "uniqueness" do
        let!(:food_list_1) { create(:food_list) }
        let!(:food_list_2) { create(:food_list) }
        let!(:food) { create(:food, name_en: "Name", name_fr: "Name", name_de: "Name", food_list: food_list_1) }
        let(:same_name_food) { build(:food, name_en: "name", name_fr: "name", name_de: "name", food_list: food_list_2) }
        let(:same_name_same_food_list_food) do
          build(:food, name_en: "name", name_fr: "name", name_de: "name", food_list: food_list_1)
        end

        it do
          expect(same_name_food).to be_valid
          expect(same_name_same_food_list_food).not_to be_valid
          expect(same_name_same_food_list_food.errors.full_messages).to contain_exactly("Name has already been taken")
        end
      end
    end
  end

  describe "Scope" do
    describe ".of_food_lists(food_lists)" do
      let!(:food_list_ch) { create(:food_list, country: build(:country, :ch)) }
      let!(:food_ch) { create(:food, food_list: food_list_ch) }
      let(:country_de) { create(:country, :de) }
      let!(:food_list_de) { create(:food_list, country: build(:country, :de)) }
      let!(:food_de) { create(:food, food_list: food_list_de) }

      it do
        expect(described_class.of_food_lists([food_list_ch])).to contain_exactly(food_ch)
        expect(described_class.of_food_lists([food_list_de])).to contain_exactly(food_de)
        expect(described_class.of_food_lists([food_list_ch, food_list_de])).to contain_exactly(food_ch, food_de)
        expect(described_class.of_food_lists([])).to be_empty
      end
    end

    describe ".order_by_annotation_count(dir)" do
      let(:cohort) { create(:cohort, :with_food_list) }
      let(:food_list) { cohort.food_lists.first }
      let(:participation) { create(:participation, cohort: cohort) }
      let(:annotation) { create(:annotation, participation: participation) }
      let!(:food_1) { create(:food, name: "food_1", food_list: food_list, annotation_items: build_list(:annotation_item, 3, annotation: annotation)) }
      let!(:food_2) { create(:food, name: "food_2", food_list: food_list, annotation_items: build_list(:annotation_item, 2, annotation: annotation)) }
      let!(:food_3) { create(:food, name: "food_3", food_list: food_list, annotation_items: build_list(:annotation_item, 3, annotation: annotation)) }
      let!(:food_4) { create(:food, name: "food_4", food_list: food_list, annotation_items: build_list(:annotation_item, 1, annotation: annotation)) }

      it do
        expect(described_class.order_by_annotation_count(:asc).to_a).to eq([food_4, food_2, food_1, food_3])
        expect(described_class.order_by_annotation_count(:desc).to_a).to eq([food_1, food_3, food_2, food_4])
      end
    end
  end
end
