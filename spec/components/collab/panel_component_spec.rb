# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::PanelComponent) do
  describe "#render" do
    context "without content" do
      it do
        render_inline(described_class.new)
        expect(rendered_content).to be_empty
      end
    end

    context "with content" do
      it do
        render_inline(described_class.new) do |component|
          component.with_title { "A title" }
          tag.p("Some content")
        end

        expect(page).to have_css("div.bg-white.shadow.overflow-hidden")
        expect(page).to have_css("div.px-4.py-5 h3.text-lg.leading-6.font-medium.text-gray-800", text: "A title")
        expect(page).to have_css("p", text: "Some content")
      end
    end
  end
end
