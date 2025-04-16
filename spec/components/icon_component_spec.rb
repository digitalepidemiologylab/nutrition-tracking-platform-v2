# frozen_string_literal: true

require "rails_helper"

RSpec.describe(IconComponent) do
  describe "#render" do
    context "when no params" do
      it do
        render_inline(described_class.new(:lock))
        expect(page).to have_css("i.ph-lock", text: nil)
      end
    end

    context "when no size, color and opacity" do
      it do
        render_inline(described_class.new(:lock, classes: "text-lg opacity-25 color-white"))
        expect(page).to have_css("i.ph-lock.text-lg.opacity-25.color-white", text: nil)
      end
    end
  end
end
