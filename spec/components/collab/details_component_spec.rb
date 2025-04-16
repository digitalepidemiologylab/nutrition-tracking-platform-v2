# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::DetailsComponent) do
  let(:title) { "A title" }

  it do
    render_inline(described_class.new) do |dc|
      dc.with_title { title }
      5.times do |i|
        dc.with_detail(label: "Detail #{i}", value: "Detail value #{i}")
      end
    end

    expect(page).to have_css("h3", text: title, count: 1)
    expect(page).to have_css("dt", count: 5)
    expect(page).to have_css("dd", count: 5)
  end
end
