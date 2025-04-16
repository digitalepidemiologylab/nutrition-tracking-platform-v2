# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Food Set select", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:food_set) { build(:food_set, cname: "hard_cheeses", name_en: "Hard cheeses") }

  before do
    create_list(:food_set, 30)
    food_set.save
    sign_in(admin)
  end

  it do
    visit(collab_food_sets_path)
    page.driver.browser.manage.window.resize_to(1200, 1500)
    expect(page).to have_css("#query")
    expect(page).to have_css("#food_sets tbody tr", minimum: 25)
    fill_in("Search by name", with: "hard")
    expect(page).to have_css("#food_sets tbody tr", count: 1)
    expect(page).to have_css("#food_sets tbody tr", text: food_set.name)
  end
end
