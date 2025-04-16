# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TabsComponent::TabComponent) do
  it "renders the tabs" do
    with_request_url "/fr" do
      render_inline(described_class.new(url: root_path, active: true)) { "Tab 3" }

      expect(page).to have_link("Tab 3", href: root_path)
    end
  end
end
