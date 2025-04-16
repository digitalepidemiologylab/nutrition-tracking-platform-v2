# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Annotate dish", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:participation) { create(:participation) }
  let(:user) { participation.user }
  let!(:food_list_1) { participation.cohort.food_lists.first }
  let!(:food_list_2) { create(:food_list, name: "Another food list") }

  let(:food_set_coffee) { create(:food_set, name_en: "Coffee") }
  let!(:coffee) do
    create(:food, name_en: "Coffee", name_fr: "Café",
      portion_quantity: 100, unit: create(:unit, :volume),
      food_sets: [food_set_coffee], food_list: food_list_1)
  end
  let!(:espresso) do
    create(:food, name_en: "Espresso", name_fr: "Espresso",
      portion_quantity: 25, unit: create(:unit, :volume),
      food_sets: [food_set_coffee], food_list: food_list_1)
  end
  let!(:americano) do
    create(:food, name_en: "Espresso", name_fr: "Espresso",
      portion_quantity: 25, unit: create(:unit, :volume),
      food_sets: [food_set_coffee], food_list: food_list_2)
  end
  let!(:cappuccino) do
    create(:food, name_en: "Cappuccino", name_fr: "Cappuccino",
      portion_quantity: 100, unit: create(:unit, :volume), food_list: food_list_1)
  end

  let!(:dish) { create(:dish, :with_dish_image, user: user) }

  let!(:annotation) do
    create(:annotation,
      :annotatable,
      dish: dish,
      participation: participation,
      annotation_items: [
        build(
          :annotation_item,
          food: coffee,
          food_set: food_set_coffee,
          present_quantity: 100, present_unit: create(:unit, :volume),
          consumed_quantity: 50, consumed_unit: create(:unit, :volume)
        )
      ])
  end

  let(:annotation_item_coffee) { dish.annotation_items.first }

  before do
    sign_in(admin)
  end

  it do # rubocop:disable RSpec/ExampleLength
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)
    expect(page).to have_css(".annotation-item", count: 1)
    expect(page).to have_text("Total consumed:\n0 g\n50.0 ml")

    # Verify that selection of a food works with tom select
    annotation_item = page.find(".annotation-item")
    within(annotation_item) do
      expect(page).to have_css(".ts-control")
      page.find(".ts-control").click
      expect(page).to have_text("Food Set - `Coffee`")
      expect(page).to have_text("Coffee")
      expect(page).to have_text("Espresso")
      expect(page).not_to have_text("Cappuccino")
      expect(page).not_to have_text("Americano")
      fill_tom_select("[name='annotation_item[food_id]']", with: "Cap")
      expect(page).to have_text("Cappuccino")
      expect(page).to have_text("= 100.0 ml")
      expect(page).not_to have_text("Other Foods")
      page.find(".ts-control").click
      expect(page).to have_text("Food Set - `Coffee`")
      expect(page).to have_text("Coffee")
      expect(page).to have_text("Espresso")
      expect(page).to have_text("Other foods")
      expect(page).to have_text("Cappuccino")
    end
    expect(page).to have_text("Total consumed:\n0 g\n100.0 ml")
  end
end
