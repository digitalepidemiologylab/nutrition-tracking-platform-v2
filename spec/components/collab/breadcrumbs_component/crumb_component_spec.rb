# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::BreadcrumbsComponent::CrumbComponent) do
  context "when url" do
    it do
      render_inline(described_class.new(crumb: {text: "1st crumb", url: "#"}))

      expect(page).to have_link(href: "#", text: "1st crumb")
    end
  end

  context "when no url" do
    it do
      render_inline(described_class.new(crumb: {text: "2nd crumb"}))

      expect(page).to have_css("span", text: "2nd crumb")
      expect(page).not_to have_css("svg")
    end
  end

  context "when counter > 0" do
    it do
      render_inline(described_class.new(crumb: {text: "2nd crumb"}, crumb_counter: 1))

      expect(page).to have_css("span", text: "2nd crumb")
      expect(page).to have_css("svg", count: 1)
    end
  end
end
