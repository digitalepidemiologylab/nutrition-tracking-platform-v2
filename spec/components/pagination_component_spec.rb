# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PaginationComponent) do
  include Pagy::Backend

  before { create_list(:dish, 3) }

  describe "#render" do
    it do
      pagy, _ = pagy(Dish.all)
      render_inline(described_class.new(pagy: pagy))
      expect(page).to have_css("div", count: 5)
      expect(page).to have_link(count: 1, text: 1)
    end
  end
end
