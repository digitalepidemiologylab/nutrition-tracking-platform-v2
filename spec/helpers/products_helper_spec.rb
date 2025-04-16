# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ProductsHelper) do
  describe "#product_default_image_url(product:)" do
    let(:product) { create(:product, image_url: image_url, product_images: product_images) }

    context "when product has image_url" do
      let(:image_url) { Faker::Internet.url }

      context "when product has no product_images" do
        let(:product_images) { [] }

        it do
          expect(helper.product_default_image_url(product: product)).to eq(image_url)
        end
      end

      context "when product has product_images" do
        let(:product_images) { create_list(:product_image, 2) }

        it do
          expect(helper.product_default_image_url(product: product)).to eq(image_url)
        end
      end
    end

    context "when product has no image_url" do
      let(:image_url) { nil }

      context "when product has no product_images" do
        let(:product_images) { [] }

        it do
          expect(helper.product_default_image_url(product: product)).to eq(image_url)
        end
      end

      context "when product has product_images" do
        let(:product_images) { create_list(:product_image, 2) }

        it do
          expect(helper.product_default_image_url(product: product)).to eq(helper.url_for(product_images.first.data.variant(:thumb)))
        end
      end
    end
  end
end
