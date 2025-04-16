# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::BreadcrumbsComponent) do
  context "when crumbs are present" do
    it "renders the content" do
      render_inline(described_class.new(crumbs: [{text: "1st crumb", url: "#"}, {text: "2nd crumb"}]))

      expect(rendered_content).to have_css("ol li", count: 2)
    end
  end

  context "when no crumbs are present" do
    it "renders the content" do
      render_inline(described_class.new)

      expect(rendered_content).to be_blank
    end
  end
end
