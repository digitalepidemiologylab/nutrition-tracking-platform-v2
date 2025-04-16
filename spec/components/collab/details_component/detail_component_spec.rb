# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::DetailsComponent::DetailComponent) do
  describe "#render" do
    let(:label) { "A label" }
    let(:value) { "A value" }

    it do
      render_inline(described_class.new(label: label, value: value))

      expect(page).to have_css("dt", text: label)
      expect(page).to have_css("dd", text: value)
    end
  end
end
