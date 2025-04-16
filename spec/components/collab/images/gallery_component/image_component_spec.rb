# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Images::GalleryComponent::ImageComponent) do
  describe "#render" do
    before { render_inline(described_class.new(image: image)) }

    context "when image is not present" do
      let(:image) { nil }

      it { expect(rendered_content).to be_blank }
    end

    context "when image is present" do
      let(:image) { create(:product_image) }

      it { expect(page).to have_css("div img", count: 1) }
    end
  end
end
