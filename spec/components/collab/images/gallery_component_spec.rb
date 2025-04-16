# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Images::GalleryComponent) do
  describe "#render" do
    context "when images are not present" do
      it do
        render_inline(described_class.new)
        expect(rendered_content).to be_blank
      end
    end

    context "when images are present" do
      let(:image_url) { Faker::LoremFlickr.image }
      let!(:image_1) { create(:product_image) }
      let!(:image_2) { create(:product_image) }

      it do
        render_inline(described_class.new) do |g|
          g.with_image(image_url: image_url)
          g.with_image(image: image_1)
          g.with_image(image: image_2)
        end
        expect(page).to have_css("div img", count: 3)
      end
    end
  end
end
