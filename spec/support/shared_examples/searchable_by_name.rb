# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples("searchable_by_name") do
  let(:searchable_factory) { described_class.name.underscore }

  describe "Callbacks" do
    before do
      allow(searchable).to receive(:refresh_search_indices)
    end

    describe "after_commit" do
      let(:searchable) { build(searchable_factory) }

      before do
        allow(searchable).to receive(:name_changed?).once.and_return(true)
      end

      it do
        searchable.save!
        expect(searchable).to have_received(:refresh_search_indices).once
      end
    end
  end

  describe "Scopes" do
    describe ".search" do
      let!(:banana) { create(searchable_factory, name_en: "Banana", name_fr: "Banane", name_de: nil) }
      let!(:peach) { create(searchable_factory, name_en: "Peach", name_fr: "Peche", name_de: nil) }
      let!(:pear) { create(searchable_factory, name_en: "Pear", name_fr: "Poire", name_de: nil) }
      let!(:cream) { create(searchable_factory, name_en: "cream >35%", name_fr: "crème >35%", name_de: nil) }
      let(:query) { "pe" }

      context "when locale = :en", :en do
        it { expect(described_class.search(query).to_a).to eq([pear, peach]) }

        context "when search term contains a special char" do
          let(:query) { ">35% cre" }

          it { expect(described_class.search(query).to_a).to eq([cream]) }
        end
      end

      context "when locale = :fr", :fr do
        it { expect(described_class.search(query).to_a).to eq([peach]) }
      end

      context "when locale = :de", :de do
        # fallback to english as german names are empty
        it { expect(described_class.search(query).to_a).to eq([pear, peach]) }
      end
    end
  end
end
