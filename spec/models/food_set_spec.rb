# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FoodSet) do
  it_behaves_like "searchable_by_name"

  describe "Associations" do
    let(:food_set) { build(:food_set) }

    it do
      expect(food_set).to have_many(:food_food_sets).dependent(:destroy)
      expect(food_set).to have_many(:foods).through(:food_food_sets)
      expect(food_set).to have_many(:annotation_items).inverse_of(:food_set).dependent(:restrict_with_error)
    end
  end

  describe "Translation" do
    let(:food_set) { build(:food_set) }

    it { expect(food_set).to translate(:name) }
  end

  describe "Validations" do
    describe "name" do
      describe "presence" do
        let!(:food_set) { build(:food_set, name_en: nil, name_fr: nil, name_de: nil, cname: "c_name") }

        it { expect(food_set).to validate_presence_of(:name) }
      end

      describe "uniqueness" do
        let!(:food_set) { create(:food_set, name_en: "Name", name_fr: "Name", name_de: "Name", cname: "c_name_1") }
        let(:same_name_food_set) do
          build(:food_set, name_en: "name", name_fr: "name", name_de: "name", cname: "c_name_2")
        end

        it do
          expect(same_name_food_set).not_to be_valid
          expect(same_name_food_set.errors.full_messages).to contain_exactly("Name has already been taken")
        end
      end
    end

    describe "cname" do
      let!(:food_set) { build(:food_set, cname: "c_name") }

      it { expect(food_set).to validate_codename_of(:cname) }

      describe "presence" do
        let!(:food_set) { build(:food_set, cname: nil, name_en: nil) }

        it { expect(food_set).to validate_presence_of(:cname) }
      end

      describe "uniqueness" do
        before { food_set.save! }

        let(:same_cname_food_set) { build(:food_set, cname: "c_name") }

        it do
          expect(same_cname_food_set).not_to be_valid
          expect(same_cname_food_set.errors.full_messages).to contain_exactly("Canonical Name has already been taken")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      before { food_set.validate }

      describe "#set_cname", :en do
        context "when cname is already set" do
          let(:food_set) { build(:food_set, cname: "a_c_name") }

          it { expect(food_set.cname).to eq("a_c_name") }
        end

        context "when cname and name_en are blank" do
          let(:food_set) { build(:food_set, cname: nil, name: nil) }

          it { expect(food_set.cname).to be_nil }
        end

        context "when cname is nil but name_en is set" do
          let!(:food_set) { build(:food_set, cname: nil, name: "A great-3d*name") }

          it { expect(food_set.cname).to eq("a_great_3d_name") }
        end
      end
    end
  end
end
