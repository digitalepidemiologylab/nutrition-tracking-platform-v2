# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FoodSetsQuery) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:fruits) { create(:food_set, cname: "fruits", name_en: "Fruits", name_fr: "Fruits") }
  let!(:cereals) { create(:food_set, cname: "cereals", name_en: "Cereals", name_fr: "Céréales") }
  let!(:vegetables) { create(:food_set, cname: "vegetables", name_en: "Vegetables", name_fr: "Légumes") }

  let(:initial_scope) { FoodSet.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::FoodSetPolicy.new(admin, FoodSet))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  describe "sorting" do
    context "when sort_by is nil" do
      let(:params) { {} }

      it "sorts by :name by default" do
        expect(result.to_a).to eq([cereals, fruits, vegetables])
      end
    end

    context "when by cname" do
      context "when direction asc" do
        let(:params) { {sort: "cname", direction: "asc"} }

        it do
          expect(result.to_a).to eq([cereals, fruits, vegetables])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "cname", direction: "desc"} }

        it do
          expect(result.to_a).to eq([vegetables, fruits, cereals])
        end
      end
    end

    context "when by name" do
      context "when direction asc" do
        let(:params) { {sort: "name", direction: "asc"} }

        it do
          expect(result.to_a).to eq([cereals, fruits, vegetables])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "name", direction: "desc"} }

        it do
          expect(result.to_a).to eq([vegetables, fruits, cereals])
        end
      end
    end
  end

  describe "#filtered" do
    context "when query is 'apri'" do
      let(:params) { {query: "veg"} }

      before { FoodSet.find_each { |f| f.refresh_search_indices } }

      it { expect(result.to_a).to eq([vegetables]) }
    end
  end
end
