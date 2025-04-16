# frozen_string_literal: true

require "rails_helper"

RSpec.describe(RefreshSearchIndicesService) do
  let!(:apricot) { create(:food, name_en: "Fresh apricot", name_fr: "Abricot", name_de: "Aprikose") }
  let!(:banana) { create(:food, name_en: "banana", name_fr: "Banane fraîche", name_de: "Bananen") }

  let(:service) { described_class.new(indexable_class: Food) }

  before do
    apricot.update_columns(tsv_document_en: nil, tsv_document_fr: nil, tsv_document_de: nil)
    banana.update_columns(tsv_document_en: nil, tsv_document_fr: nil, tsv_document_de: nil)
  end

  describe "#call" do
    context "when no food_ids are passed" do
      it do
        service.call

        # #refresh_search_indices is called in after_commit callback
        apricot.reload
        banana.reload
        expect(apricot.tsv_document_en).to eq("'apricot':2 'fresh':1")
        expect(apricot.tsv_document_fr).to eq("'abricot':1")
        expect(apricot.tsv_document_de).to eq("'aprikose':1")
        expect(banana.tsv_document_en).to eq("'banana':1")
        expect(banana.tsv_document_fr).to eq("'banane':1 'fraiche':2")
        expect(banana.tsv_document_de).to eq("'bananen':1")
      end
    end

    context "when one food_ids is passed" do
      it do
        service.call(ids: banana.id)

        # #refresh_search_indices is called in after_commit callback
        apricot.reload
        banana.reload
        expect(apricot.tsv_document_en).to be_nil
        expect(apricot.tsv_document_fr).to be_nil
        expect(apricot.tsv_document_de).to be_nil
        expect(banana.tsv_document_en).to eq("'banana':1")
        expect(banana.tsv_document_fr).to eq("'banane':1 'fraiche':2")
        expect(banana.tsv_document_de).to eq("'bananen':1")
      end
    end
  end
end
