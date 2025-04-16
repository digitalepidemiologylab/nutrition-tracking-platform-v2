# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FoodsQuery) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:banana) {
    create(:food, name_en: "Banana", name_fr: "Banane", food_sets: [food_set_fruit_skin],
      unit: create(:unit, :energy), food_list: food_list_ch)
  }
  let!(:apricot) {
    create(:food, name_en: "Apricot", name_fr: "Abricot", food_sets: [food_set_fruit_pit],
      unit: create(:unit, :volume), food_list: food_list_de)
  }
  let!(:cherry) {
    create(:food, name_en: "Cherry", name_fr: "Cerise", food_sets: [food_set_fruit_red],
      unit: create(:unit, :mass), food_list: food_list_us)
  }
  let!(:food_set_fruit_skin) { build(:food_set, name_en: "Skinny fruit") }
  let!(:food_set_fruit_pit) { build(:food_set, name_en: "Pitty fruit") }
  let!(:food_set_fruit_red) { build(:food_set, name_en: "Red fruit") }

  let!(:food_list_ch) { create(:food_list, country: create(:country, :ch), name: "Swiss food list") }
  let!(:food_list_de) { create(:food_list, country: create(:country, :de), name: "German food list") }
  let!(:food_list_us) { create(:food_list, country: create(:country, :us), name: "American food list") }

  let(:initial_scope) { Food.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::FoodPolicy.new(admin, Food))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  describe "filter" do
    context "when food_list_ids param is present" do
      context "when food_list_ids is valid" do
        let(:params) { {food_list_ids: [food_list_de.id]} }

        it do
          expect(result.to_a).to eq([apricot])
        end
      end

      context "when food_list_ids is invalid" do
        let(:params) { {food_list_ids: "INV"} }

        it do
          expect(result.to_a).to be_empty
        end
      end
    end
  end

  describe "sorting" do
    context "when sort_by is nil" do
      let(:params) { {} }

      it "sorts by :name by default" do
        expect(result.to_a).to eq([apricot, banana, cherry])
      end
    end

    context "when by name" do
      context "when direction asc" do
        let(:params) { {sort: "name", direction: "asc"} }

        it do
          expect(result.to_a).to eq([apricot, banana, cherry])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "name", direction: "desc"} }

        it do
          expect(result.to_a).to eq([cherry, banana, apricot])
        end
      end
    end

    context "when by food_list" do
      context "when direction asc" do
        let(:params) { {sort: "food_list", direction: "asc"} }

        it do
          expect(result.to_a).to eq([cherry, apricot, banana])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "food_list", direction: "desc"} }

        it do
          expect(result.to_a).to eq([banana, apricot, cherry])
        end
      end
    end

    context "when by unit" do
      context "when direction asc" do
        let(:params) { {sort: "unit", direction: "asc"} }

        it do
          expect(result.to_a).to eq([apricot, banana, cherry])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "unit", direction: "desc"} }

        it do
          expect(result.to_a).to eq([cherry, banana, apricot])
        end
      end
    end
  end

  describe "#filtered" do
    context "when query is 'apri'" do
      let(:params) { {query: "apri"} }

      before { Food.find_each { |f| f.refresh_search_indices } }

      it { expect(result.to_a).to eq([apricot]) }
    end
  end
end
