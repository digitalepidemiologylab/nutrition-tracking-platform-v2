# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Delete annotation items", :js) do
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
  let!(:cherry) do
    create(:food, food_list: food_list, name_en: "Cherry", name_fr: "Cerise",
      portion_quantity: 30, unit: create(:unit, :mass))
  end

  let!(:annotation) do
    create(:annotation,
      :annotatable,
      participation: participation,
      dish: dish,
      annotation_items: [
        build(:annotation_item,
          present_quantity: 30, present_unit: create(:unit, :volume),
          consumed_quantity: 40, consumed_unit: create(:unit, :volume),
          food: apricot),
        build(:annotation_item,
          present_quantity: 50, present_unit: create(:unit, :volume),
          consumed_quantity: nil, consumed_unit: nil,
          food: cherry),
        build(:annotation_item,
          present_quantity: 10, present_unit: create(:unit, :mass),
          consumed_quantity: 20, consumed_unit: create(:unit, :mass),
          food: banana)
      ])
  end

  before do
    sign_in(admin)
  end

  it do # rubocop:disable RSpec/ExampleLength
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)
    expect(page).to have_css(".annotation-item", count: 3)
    expect(page).to have_text("Total consumed:\n20.0 g\n90.0 ml")
    expect(page).not_to have_css("div[data-tippy-root]")

    expect(page).to have_css("#destroy_annotation_items", text: "Delete")
    destroy_link = page.first("#destroy_annotation_items")
    expect(destroy_link[:disabled]).to eq("true")
    destroy_link.hover
    expect(page).to have_css("div[data-tippy-root]")
    select_annotation_items_checkboxes = page.all("[name='annotations_selected_annotation_items[annotation_item_ids]']")
    select_annotation_items_checkboxes.first.click
    expect(destroy_link[:disabled]).to eq("false")
    select_annotation_items_checkboxes.last.click
    expect(destroy_link[:disabled]).to eq("false")
    destroy_link.click
    sleep(0.2)
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to eq("Are you sure?")
    alert.accept
    expect(page).to have_css(".annotation-item", count: 1)
    expect(page).to have_css("#flash_messages", text: "Items deleted successfully")
    expect(destroy_link[:disabled]).to eq("true")
  end
end
