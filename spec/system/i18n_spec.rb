# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Food Set select", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:food) { create(:food, :editable) }

  before do
    create(:food_set, name: "pizza margherita")
    sign_in(admin)
  end

  it do # rubocop:disable RSpec/ExampleLength
    visit(edit_collab_food_path(food))
    page.driver.browser.manage.window.resize_to(1200, 1500)
    expect(page).to have_css(".ts-control")
    page.find(".ts-control").click
    select_element = page.find("[name='food[food_set_ids][]']")
    container = select_element.find(:xpath, "..")

    within(container) do
      find("input").send_keys("abcdef")
      expect(container).to have_text("No results")
    end

    visit(edit_collab_food_path(food, locale: :fr))
    expect(page).to have_css(".ts-control")
    page.find(".ts-control").click
    select_element = page.find("[name='food[food_set_ids][]']")
    container = select_element.find(:xpath, "..")

    within(container) do
      find("input").send_keys("abcdef")
      expect(container).to have_text("Pas de résultats")
    end

    visit(edit_collab_food_path(food, locale: :de))
    expect(page).to have_css(".ts-control")
    page.find(".ts-control").click
    select_element = page.find("[name='food[food_set_ids][]']")
    container = select_element.find(:xpath, "..")

    within(container) do
      find("input").send_keys("abcdef")
      expect(container).to have_text("Keine Ergebnisse")
    end
  end
end
