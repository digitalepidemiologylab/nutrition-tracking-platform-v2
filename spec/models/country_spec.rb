# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Country) do
  describe "Associations" do
    let(:country) { build(:country, :ch) }

    it do
      expect(country).to have_many(:food_lists).inverse_of(:country).dependent(:restrict_with_error)
    end
  end

  describe "Translation" do
    let(:country) { build(:country) }

    it { expect(country).to translate(:name) }
  end

  describe "Validations" do
    let(:country) { build(:country) }

    it { expect(country).to be_valid }

    describe "id" do
      it do
        expect(country).to validate_uniqueness_of(:id).case_insensitive.with_message("has already been taken")
        expect(country)
          .to validate_length_of(:id).is_equal_to(2).with_message("is the wrong length (should be 2 characters)")
      end
    end
  end

  describe "#id=(id)" do
    it "upcases ID" do
      country = build(:country, id: "fr")
      expect(country.id).to eq("FR")
    end
  end

  describe "#destroy" do
    let!(:country) { create(:country) }

    context "when no associated models exist" do
      it { expect(country.destroy).to be_destroyed }
    end

    context "when associated models exist" do
      let!(:food_list) { create(:food_list, country: country) }

      it do
        country.destroy
        expect(country).not_to be_destroyed
        expect(country.errors[:base]).to contain_exactly("Cannot delete record because dependent food lists exist")
      end
    end
  end
end
