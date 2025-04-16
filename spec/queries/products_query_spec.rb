# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ProductsQuery) do
  let!(:admin) { create(:collaborator, :admin) }

  let!(:coke) {
    create(:product, barcode: "5449000000286", unit: create(:unit, :volume), portion_quantity: "250",
      name_en: "Coke", name_fr: "Coca-Cola")
  }
  let!(:mars) {
    create(:product, barcode: "5000159407236", unit: create(:unit, :mass), portion_quantity: "51",
      name_en: "Mars", name_fr: "Mars")
  }
  let!(:nutella) {
    create(:product, barcode: "59032823", unit: create(:unit, :mass), portion_quantity: "15",
      name_en: "Nutella", name_fr: "Mars")
  }

  let(:initial_scope) { Product.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::ProductPolicy.new(admin, Product))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  describe "filter" do
    context "when query param is a barcode" do
      context "when barcode is valid" do
        let(:params) { {query: coke.barcode} }

        it { expect(result.to_a).to eq([coke]) }
      end
    end

    context "when query param is a name" do
      context "when name exists" do
        let(:params) { {query: "Nutel"} }

        it { expect(result.to_a).to eq([nutella]) }
      end
    end

    context "when query param is neither a barcode or a name" do
      let(:params) { {query: "INV"} }

      it { expect(result.to_a).to be_empty }
    end
  end

  describe "sorting" do
    context "when sort_by is nil" do
      let(:params) { {} }

      it "sorts by :name by default" do
        expect(result.to_a).to eq([coke, mars, nutella])
      end
    end

    context "when by name" do
      context "when direction asc" do
        let(:params) { {sort: "name", direction: "asc"} }

        it { expect(result.to_a).to eq([coke, mars, nutella]) }
      end

      context "when direction desc" do
        let(:params) { {sort: "name", direction: "desc"} }

        it { expect(result.to_a).to eq([nutella, mars, coke]) }
      end
    end

    context "when by barcode" do
      context "when direction asc" do
        let(:params) { {sort: "barcode", direction: "asc"} }

        it { expect(result.to_a).to eq([mars, coke, nutella]) }
      end

      context "when direction desc" do
        let(:params) { {sort: "barcode", direction: "desc"} }

        it { expect(result.to_a).to eq([nutella, coke, mars]) }
      end
    end

    context "when by unit" do
      context "when direction asc" do
        let(:params) { {sort: "unit", direction: "asc"} }

        it { expect(result.to_a).to eq([coke, mars, nutella]) }
      end

      context "when direction desc" do
        let(:params) { {sort: "unit", direction: "desc"} }

        it { expect(result.to_a).to eq([nutella, mars, coke]) }
      end
    end

    context "when by status" do
      before do
        mars.mark_incomplete!
        nutella.mark_complete!
      end

      context "when direction asc" do
        let(:params) { {sort: "status", direction: "asc"} }

        it { expect(result.to_a).to eq([coke, mars, nutella]) }
      end

      context "when direction desc" do
        let(:params) { {sort: "status", direction: "desc"} }

        it { expect(result.to_a).to eq([nutella, mars, coke]) }
      end
    end
  end
end
