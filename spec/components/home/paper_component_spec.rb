# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Home::PaperComponent) do
  it "renders the content" do
    render_inline(described_class.new(
      journal: "A journal, 2022",
      title: "A title",
      authors: "Some authors",
      url: "https://www.digitalepidemiologylab.org"
    ))

    expect(page).to have_css("span", text: "A journal, 2022")
    expect(page).to have_link("A title", href: "https://www.digitalepidemiologylab.org")
    expect(page).to have_css("p", text: "Some authors")
  end
end
