# frozen_string_literal: true

require "rails_helper"

RSpec.describe(BadgeComponent) do
  describe "render" do
    context "with no color" do
      it do
        render_inline(described_class.new) { "Badge 1" }
        expect(page).to have_css("span.bg-gray-200.text-gray-800", text: "Badge 1")
      end
    end

    context "with color" do
      before { render_inline(described_class.new(color: color)) { "Badge 1" } }

      context "when green" do
        let(:color) { :green }

        it { expect(page).to have_css("span.bg-positive.text-white", text: "Badge 1") }
      end

      context "when brand" do
        let(:color) { :brand }

        it { expect(page).to have_css("span.bg-brand.text-white", text: "Badge 1") }
      end

      context "when :yellow" do
        let(:color) { :yellow }

        it { expect(page).to have_css("span.bg-gray-200.text-gray-800", text: "Badge 1") }
      end
    end
  end
end
