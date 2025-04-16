# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::PanelComponent::TitleComponent) do
  describe "#render" do
    let(:title) { "A details title" }

    it do
      render_inline(described_class.new) { title }

      expect(page).to have_css("h3", text: title)
    end
  end
end
