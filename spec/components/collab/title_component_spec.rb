# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::TitleComponent) do
  it do
    render_inline(described_class.new) do |tc|
      tc.with_action { link_to("home", root_path, class: "btn btn-primary") }
      "The Title"
    end

    expect(page).to have_css("div.max-w-full.px-4")
    expect(page).to have_text("The Title")
    expect(page).to have_link("home")
  end
end
