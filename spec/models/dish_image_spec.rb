# frozen_string_literal: true

require "rails_helper"

RSpec.describe(DishImage) do
  it_behaves_like "base_image"

  describe "Associations" do
    let(:dish_image) { build(:dish_image) }

    it do
      expect(dish_image).to belong_to(:dish).inverse_of(:dish_image)
      expect(dish_image).to have_many(:segmentations).inverse_of(:dish_image).dependent(:destroy)
      expect(dish_image).to have_many(:polygon_sets).inverse_of(:dish_image).dependent(:destroy)
      expect(dish_image).to have_one_attached(:data)
    end
  end

  describe "Validations" do
    describe "basic" do
      let(:dish_image) { build(:dish_image) }

      it { expect(dish_image).to be_valid }
    end
  end
end
