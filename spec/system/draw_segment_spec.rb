# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Draw segment", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:participation) { create(:participation) }
  let!(:food_list) { participation.cohort.food_lists.first }
  let!(:dish) { create(:dish, :with_dish_image, user: participation.user) }

  let!(:banana) do
    create(:food, food_list: food_list, name_en: "Banana", name_fr: "Banane",
      portion_quantity: 10, unit: create(:unit, :mass))
  end
  let!(:apricot) do
    create(:food, food_list: food_list, name_en: "Apricot", name_fr: "Abricot",
      portion_quantity: 20, unit: create(:unit, :mass))
  end

  let!(:annotation) do
    create(:annotation,
      :annotatable,
      dish: dish,
      participation: participation,
      annotation_items: [
        build(:annotation_item,
          present_quantity: 30, present_unit: create(:unit, :volume),
          consumed_quantity: 40, consumed_unit: create(:unit, :volume),
          food: apricot)
      ])
  end

  let(:annotation_item_apricot) { dish.annotation_items.reload.first }

  before do
    sign_in(admin)
  end

  it do # rubocop:disable RSpec/ExampleLength
    # Verify that highlighted polygons is blank before we draw it
    page.driver.browser.manage.window.resize_to(2000, 1500)
    visit(collab_annotation_path(annotation))
    expect(page).not_to have_button(text: "Clear Polygons")
    page.find(".annotation-item").click
    sleep(0.2) # we need some time for the already existing canvas to be replaced from server
    expect(page).to have_button(text: "Clear Polygons")
    canvas = find("canvas")
    expect(JSON.parse(canvas["data-canvas-polygons-value"]))
      .to eq([{"id" => annotation_item_apricot.id, "index" => 1, "colorIndex" => 0, "polygons" => nil}])
    expect(canvas["data-canvas-annotation-item-id-value"])
      .to eq(annotation_item_apricot.id)

    # Verify that highlighted polygons is not blank after we draw it
    page.driver.browser.action.move_to(canvas.native, -195, -195)
      .click_and_hold
      .move_to(canvas.native, -150, -50)
      .move_to(canvas.native, 200, 200)
      .move_to(canvas.native, 250, 320)
      .move_to(canvas.native, -250, 295)
      .release
      .perform
    sleep(0.2)
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"]).first
    expect(polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    rounded_polygon_coordinates = round_polygon_coordinates(polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.24, 0.24], [0.3, 0.43], [0.76, 0.76], [0.83, 0.92], [0.17, 0.89]])
    expect(canvas["data-canvas-annotation-item-id-value"])
      .to eq(annotation_item_apricot.id)

    # Deselect annotation item and verify that no polygons are highlighted
    page.first("dl").click
    sleep(0.2)
    expect(page).not_to have_button(text: "Clear Polygons")
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"]).first
    expect(polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    rounded_polygon_coordinates = round_polygon_coordinates(polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.24, 0.24], [0.3, 0.43], [0.76, 0.76], [0.83, 0.92], [0.17, 0.89]])
    expect(canvas["data-canvas-annotation-item-id-value"])
      .to be_blank

    # Reload the page, select the annotation item and verify that the corresponding polygons are highlighted
    visit(collab_annotation_path(annotation))
    page.find(".annotation-item").click
    sleep(0.2)
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"]).first
    expect(polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(polygons_data["id"]).to eq(annotation_item_apricot.id)
    expect(polygons_data["index"]).to eq(1)
    expect(polygons_data["colorIndex"]).to eq(0)
    rounded_polygon_coordinates = round_polygon_coordinates(polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.24, 0.24], [0.3, 0.43], [0.76, 0.76], [0.83, 0.92], [0.17, 0.89]])
    expect(canvas["data-canvas-annotation-item-id-value"])
      .to eq(annotation_item_apricot.id)

    # Add another annotation item
    click_button("Add Food")
    expect(page).to have_css(".annotation-item", count: 2)
    annotation.annotation_items.reload
    expect(annotation_item_apricot).to eq(annotation.annotation_items.first)
    annotation_item_new = annotation.annotation_items.last

    # Draw a new polygons for the new annotation item
    sleep(0.2)
    canvas = find("canvas")
    page.driver.browser.action.move_to(canvas.native, 305, -310)
      .click_and_hold
      .move_to(canvas.native, 150, -205)
      .move_to(canvas.native, 0, 100)
      .move_to(canvas.native, 250, 0)
      .move_to(canvas.native, 320, -250)
      .release
      .perform
    sleep(0.2)
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"])
    expect(polygons_data.length).to eq(2)

    first_polygons_data = polygons_data.first
    second_polygons_data = polygons_data.last
    expect(first_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(first_polygons_data["id"]).to eq(annotation_item_apricot.id)
    expect(first_polygons_data["index"]).to eq(1)
    expect(first_polygons_data["colorIndex"]).to eq(0)
    rounded_polygon_coordinates = round_polygon_coordinates(first_polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.24, 0.24], [0.3, 0.43], [0.76, 0.76], [0.83, 0.92], [0.17, 0.89]])

    expect(second_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(second_polygons_data["id"]).to eq(annotation_item_new.id)
    expect(second_polygons_data["index"]).to eq(2)
    expect(second_polygons_data["colorIndex"]).to eq(1)
    rounded_polygon_coordinates = round_polygon_coordinates(second_polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.9, 0.09], [0.7, 0.23], [0.5, 0.63], [0.83, 0.5], [0.92, 0.17]])

    # Select the first created annotation item
    page.all(".annotation-item").last.click # rubocop:disable Rails/RedundantActiveRecordAllMethod
    sleep(0.2)
    expect(page).to have_button(text: "Clear Polygons")
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"])
    expect(polygons_data.length).to eq(2)

    first_polygons_data = polygons_data.first
    second_polygons_data = polygons_data.last

    expect(first_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(first_polygons_data["id"]).to eq(annotation_item_apricot.id)
    expect(first_polygons_data["index"]).to eq(1)
    expect(first_polygons_data["colorIndex"]).to eq(0)
    rounded_polygon_coordinates = round_polygon_coordinates(first_polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.24, 0.24], [0.3, 0.43], [0.76, 0.76], [0.83, 0.92], [0.17, 0.89]])

    expect(second_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(second_polygons_data["id"]).to eq(annotation_item_new.id)
    expect(second_polygons_data["index"]).to eq(2)
    expect(second_polygons_data["colorIndex"]).to eq(1)
    rounded_polygon_coordinates = round_polygon_coordinates(second_polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.9, 0.09], [0.7, 0.23], [0.5, 0.63], [0.83, 0.5], [0.92, 0.17]])

    # Clear highlighted polygons
    click_button("Clear")
    sleep(0.2)
    canvas = find("canvas")
    polygons_data = JSON.parse(canvas["data-canvas-polygons-value"])
    expect(polygons_data.length).to eq(2)

    first_polygons_data = polygons_data.first
    second_polygons_data = polygons_data.last

    expect(first_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(first_polygons_data["id"]).to eq(annotation_item_new.id)
    expect(first_polygons_data["index"]).to eq(2)
    expect(first_polygons_data["colorIndex"]).to eq(1)
    rounded_polygon_coordinates = round_polygon_coordinates(first_polygons_data["polygons"].first)
    expect(rounded_polygon_coordinates).to eq([[0.9, 0.09], [0.7, 0.23], [0.5, 0.63], [0.83, 0.5], [0.92, 0.17]])

    expect(second_polygons_data.keys).to contain_exactly("id", "index", "colorIndex", "polygons")
    expect(second_polygons_data["id"]).to eq(annotation_item_apricot.id)
    expect(second_polygons_data["index"]).to eq(1)
    expect(second_polygons_data["colorIndex"]).to eq(0)
    expect(second_polygons_data["polygons"]).to be_nil

    expect(canvas["data-canvas-annotation-item-id-value"])
      .to eq(annotation_item_apricot.id)
  end
end

private def round_polygon_coordinates(coordinates_data)
  coordinates_data.map do |coordinates|
    coordinates.map { |coordinate| coordinate.round(2) }
  end
end
