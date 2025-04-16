# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FoodListsQuery) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:food_list_ch) { create(:food_list, country: create(:country, :ch), name: "Swiss food list") }
  let!(:food_list_de) { create(:food_list, country: create(:country, :de), name: "German food list") }
  let!(:food_list_us) { create(:food_list, country: create(:country, :us), name: "American food list") }

  let(:initial_scope) { FoodList.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::FoodListPolicy.new(admin, FoodList))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  describe "filter" do
    context "when query param is present" do
      context "when query param is valid" do
        let(:params) { {query: "wiss"} }

        it do
          expect(result.to_a).to eq([food_list_ch])
        end
      end

      context "when country_id is invalid" do
        let(:params) { {query: "INV%2"} }

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
        expect(result.to_a).to eq([food_list_us, food_list_de, food_list_ch])
      end
    end

    context "when by name" do
      context "when direction asc" do
        let(:params) { {sort: "name", direction: "asc"} }

        it do
          expect(result.to_a).to eq([food_list_us, food_list_de, food_list_ch])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "name", direction: "desc"} }

        it do
          expect(result.to_a).to eq([food_list_ch, food_list_de, food_list_us])
        end
      end
    end

    context "when by country" do
      context "when direction asc" do
        let(:params) { {sort: "country", direction: "asc"} }

        it do
          expect(result.to_a).to eq([food_list_de, food_list_ch, food_list_us])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "country", direction: "desc"} }

        it do
          expect(result.to_a).to eq([food_list_us, food_list_ch, food_list_de])
        end
      end
    end
  end

  describe "#filtered" do
    context "when query is 'apri'" do
      let(:params) { {query: "Swiss"} }

      it { expect(result.to_a).to eq([food_list_ch]) }
    end
  end
end
