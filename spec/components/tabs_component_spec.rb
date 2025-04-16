# frozen_string_literal: true

require "rails_helper"

describe(TabsComponent) do
  it "renders the tabs" do
    with_request_url "/fr" do
      render_inline(described_class.new) do |tc|
        tc.with_tab(url: root_path) { "Tab 1" }
        tc.with_tab(url: root_path) { "Tab 2" }
        tc.with_tab(url: root_path, active: true) { "Tab 3" }
      end

      expect(page).to have_css("div")
      expect(page).to have_link("Tab 1", href: root_path)
      expect(page).to have_link("Tab 2", href: root_path)
      expect(page).to have_link("Tab 3", href: root_path)
    end
  end
end
