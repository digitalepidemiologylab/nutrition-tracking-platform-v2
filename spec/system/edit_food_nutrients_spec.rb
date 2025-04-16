# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Food Set select", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:food) { create(:food, :editable, food_nutrients: [build(:food_nutrient, nutrient: nutrient_1)]) }
  let!(:nutrient_1) { create(:nutrient) }
  let!(:nutrient_2) { create(:nutrient) }
  let!(:nutrient_3) { create(:nutrient) }

  before do
    sign_in(admin)
  end

  it do
    visit(edit_collab_food_path(food))
    page.driver.browser.manage.window.resize_to(1200, 1500)
    expect(page).to have_css("[data-controller=\"food-nutrients--form\"]", count: 1)
    click_link("Add a nutrient")
    expect(page).to have_css("[data-controller=\"food-nutrients--form\"]", count: 2)
    click_link("Delete")
    expect(page).to have_css("[data-controller=\"food-nutrients--form\"]", count: 1)
    click_link("Add a nutrient")
    expect(page).to have_css("[data-controller=\"food-nutrients--form\"]", count: 2)
    forms = page.all("[data-controller=\"food-nutrients--form\"]")
    within(forms.last) do
      select(nutrient_2.name, from: "Nutrient")
      fill_in("Per 100", with: 10)
      sleep(1)
    end
    click_button("Update Food")
    expect(page).to have_current_path(collab_food_path(food))
    expect(page).to have_css("table tbody tr", count: 2)
  end
end
