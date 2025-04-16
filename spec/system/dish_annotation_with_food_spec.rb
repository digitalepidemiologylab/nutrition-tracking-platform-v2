# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Annotate dish", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:participation) { create(:participation) }
  let!(:food_list) { participation.cohort.food_lists.first }
  let!(:dish) { create(:dish, user: participation.user) }

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
      dish: dish,
      participation: participation,
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

    # Verify that clicking a dish item properly add/remove the :selected attribute
    annotation_items = page.all(".annotation-item")
    annotation_item_1 = annotation_items[0]
    annotation_item_2 = annotation_items[1]

    within annotation_item_2 do
      expect(page).to have_text("= 50.0 ml")
    end
    expect { annotation_item_2.click }.to change { annotation_item_2[:selected] }.from(nil)
    expect { annotation_item_1.click }.to change { annotation_item_1[:selected] }.from(nil)
      .and(change { annotation_item_2[:selected] }.to(nil))

    # Verify that selection of a food works with tom select
    within(annotation_item_2) do
      expect(page).to have_text("= 50.0 ml")
      expect(page).to have_css(".ts-control")
      page.find(".ts-control").click
      fill_tom_select("[name='annotation_item[food_id]']", with: "straw")
    end
    expect(page).to have_text("Total consumed:\n90.0 g\n40.0 ml")

    # Reload annotation items
    annotation_items = page.all(".annotation-item")
    annotation_item_1 = annotation_items[0]
    annotation_item_2 = annotation_items[1]
    within(annotation_item_2) do
      expect(annotation_item_2).to have_content("= 70.0 g")
      food_select = find("select[name='annotation_item[food_id]']", visible: false)
      expect(food_select.value).to eq(strawberry.id)
    end

    # Delete a annotation item, and check that the remaining one is deselected
    annotation_item_1.click
    expect(annotation_item_1[:selected]).to be_truthy
    expect(annotation_item_2[:selected]).to be_falsy
    within(annotation_item_2) do
      click_link(title: "Delete")
    end
    sleep(0.2) # Wait for alert to appear
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to eq("Are you sure?")

    alert.accept
    expect(page).to have_css(".annotation-item", count: 2)
    expect(annotation_item_1[:selected]).to be_falsy
    expect(page).to have_text("Total consumed:\n20.0 g\n40.0 ml")

    # Add another annotation item
    click_button("Add Food")
    expect(page).to have_css(".annotation-item", count: 3)
    last_annotation_item_element = page.all(".annotation-item")[0]
    within(last_annotation_item_element) do
      expect(page).to have_css(".ts-control", text: "Cherry")
      expect(page).to have_content("= 30.0 g")
      expect(page).to have_content("Cherry")
    end

    # Check that newly added annotation item is selected
    last_annotation_id = AnnotationItem.last.id
    expect(page).to have_text("Total consumed:\n50.0 g\n40.0 ml")
    expect(last_annotation_item_element[:selected]).to be_truthy
    expect(last_annotation_item_element["data-id"]).to eq(last_annotation_id)
  end
end
