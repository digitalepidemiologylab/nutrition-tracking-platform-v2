# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::TableComponent::RowComponent) do
  describe "#render" do
    it do
      render_inline(described_class.new) do |r|
        2.times do |i|
          r.with_row_td { i }
        end
      end

      expect(page).to have_css("tr", count: 1)
      expect(page).to have_css("tr td", count: 2)
    end
  end
end
