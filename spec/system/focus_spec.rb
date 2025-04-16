# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Focus in annotation item form", :js) do
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
  let!(:pear) do
    create(:food, food_list: food_list, name_en: "Pear", name_fr: "Poire",
      portion_quantity: 40, unit: create(:unit, :mass))
  end
  let!(:strawberry) do
    create(:food, food_list: food_list, name_en: "Strawberry", name_fr: "Fraise",
      portion_quantity: 70, unit: create(:unit, :mass))
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

  it do
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)

    annotation_items = page.all(".annotation-item")
    annotation_item_2 = annotation_items[1]

    # Selecting an option in a tom-select element move the focus to next input element
    # as focusing a tom-select opens it which feels weird
    within(annotation_item_2) do
      page.find(".ts-control").click
      fill_tom_select("[name='annotation_item[food_id]']", with: "straw")
    end
    sleep(0.2)

    # Select in an input element keep the focus in this element
    expect(page).to have_css("input:focus", id: "2_annotation_item_present_quantity")
    fill_in("2_annotation_item_consumed_quantity", with: 200)
    select("g", from: "2_annotation_item_consumed_unit_id")
    sleep(0.2)
    expect(page).to have_css("select:focus", id: "2_annotation_item_consumed_unit_id")
  end
end
