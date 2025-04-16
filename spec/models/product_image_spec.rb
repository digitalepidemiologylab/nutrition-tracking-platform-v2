# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ProductImage) do
  it_behaves_like "base_image"

  describe "Associations" do
    let(:product_image) { build(:product_image) }

    it { expect(product_image).to belong_to(:product).inverse_of(:product_images) }
    it { expect(product_image).to have_one_attached(:data) }
  end

  describe "Validations" do
    describe "basic" do
      let(:product_image) { build(:product_image) }

      it { expect(product_image).to be_valid }
    end
  end
end
