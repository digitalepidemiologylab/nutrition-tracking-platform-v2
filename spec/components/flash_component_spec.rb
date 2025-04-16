# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FlashComponent) do
  it "renders the content" do
    render_inline(described_class.new(flash: [:error, "Something weird happened"]))

    expect(page).to have_css(".text-sm.font-medium.text-gray-800", text: "Something weird happened")
    expect(page).to have_css(".ph-warning-circle.text-brand.text-2xl")
  end
end
