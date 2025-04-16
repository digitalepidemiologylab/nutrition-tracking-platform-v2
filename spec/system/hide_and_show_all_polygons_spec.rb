# frozen_string_literal: true

require "rails_helper"

describe("Hide/show all polygons", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:dish) { create(:dish, :with_dish_image, user: build(:user)) }

  let!(:annotation) do
    create(
      :annotation,
      :annotatable,
      dish: dish,
      annotation_items: build_list(:annotation_item, 2, :with_polygon_set, food: build(:food))
    )
  end

  before do
    sign_in(admin)
  end

  it do
    page.driver.browser.manage.window.resize_to(2000, 1500)
    visit(collab_annotation_path(annotation))
    page.first(".annotation-item").click
    expect(page).to have_link("Hide All Polygons")
    expect(page).to have_css("canvas", count: 1)
    click_link("Hide All Polygons")
    expect(page).not_to have_css("canvas")
    expect(page).to have_link("Show All Polygons")
    expect(page).not_to have_link("Hide All Polygons")
    click_link("Show All Polygons")
    expect(page).to have_css("canvas", count: 1)
    expect(page).to have_link("Hide All Polygons")
    expect(page).not_to have_link("Show All Polygons")
  end
end
