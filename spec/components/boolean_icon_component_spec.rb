# frozen_string_literal: true

require "rails_helper"

RSpec.describe(BooleanIconComponent) do
  describe "#render" do
    context "when the boolean value is true" do
      it do
        render_inline(described_class.new(true))
        expect(page).to have_css("i.ph-check-circle-fill.text-positive")
      end
    end

    context "when the boolean value is false" do
      it do
        render_inline(described_class.new(false))
        expect(page).to have_css("i.ph-x-circle-fill.text-brand")
      end
    end
  end
end
