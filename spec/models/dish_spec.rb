# frozen_string_literal: true

require "rails_helper"

describe(Dish) do
  describe "Associations" do
    let(:dish) { build(:dish) }

    it { expect(dish).to be_versioned }

    it do
      expect(dish).to belong_to(:user).inverse_of(:dishes)
      expect(dish).to have_many(:annotations).inverse_of(:dish).dependent(:destroy)
      expect(dish).to have_many(:annotation_items).through(:annotations)
      expect(dish).to have_many(:participations).through(:user)
      expect(dish).to have_one(:dish_image).inverse_of(:dish).dependent(:destroy)
    end
  end

  describe "Validations" do
    describe "id" do
      let!(:dish) { create(:dish) }

      it { expect(dish).to validate_uniqueness_of(:id).case_insensitive }
    end

    describe "annotation presence" do
      let!(:dish) { build(:dish) }

      context "when dish has annotations" do
        it { expect(dish.annotations).not_to be_empty }
        it { expect(dish).to be_valid }
      end

      context "when dish has no annotations" do
        before { dish.annotations = [] }

        it { expect(dish.annotations).to be_empty }

        it do
          expect(dish).not_to be_valid
          expect(dish.errors.full_messages).to contain_exactly("Annotations can't be blank")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      describe "#set_private" do
        let(:user) { build(:user, dishes_private: dishes_private) }

        context "when created" do
          before { dish.validate }

          let(:dish) { build(:dish, user: user) }

          context "when user dishes_private is nil" do
            let(:dishes_private) { nil }

            it { expect(dish).not_to(be_private) }
          end

          context "when user dishes_private is false" do
            let(:dishes_private) { false }

            it { expect(dish).not_to(be_private) }
          end

          context "when user dishes_private is true" do
            let(:dishes_private) { true }

            it { expect(dish).to(be_private) }
          end
        end

        context "when updated" do
          let!(:user) { build(:user, dishes_private: false) }
          let!(:dish) { create(:dish, user: user) }

          before do
            dish.update_columns(private: true)
            dish.validate
          end

          it { expect(dish).to(be_private) }
        end
      end
    end
  end

  describe "#has_image?" do
    let(:dish) { create(:dish, dish_image: dish_image) }

    context "when dish has image" do
      let(:dish_image) { create(:dish_image) }

      it { expect(dish).to have_image }
    end

    context "when dish has no image" do
      let(:dish_image) { nil }

      it { expect(dish).not_to have_image }
    end
  end
end
