# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Annotate dish with product", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:participation) { create(:participation) }
  let!(:food_list) { participation.cohort.food_lists.first }
  let!(:dish) { create(:dish, user: participation.user) }

  let!(:apricot) do
    create(:food, food_list: food_list, name_en: "Apricot", name_fr: "Abricot",
      portion_quantity: 20, unit: create(:unit, :mass))
  end
  let!(:coke) {
    create(:product, barcode: "5449000000286", unit: create(:unit, :volume), portion_quantity: "250", name_en: "Coke",
      name_fr: "Coca-Cola")
  }
  let!(:mars) {
    create(:product, barcode: "5000159407236", unit: create(:unit, :mass), portion_quantity: "51", name_en: "Mars",
      name_fr: "Mars")
  }

  let!(:annotation) do
    create(:annotation,
      participation: participation,
      dish: dish,
      annotation_items: [
        build(:annotation_item,
          present_quantity: 30, present_unit: create(:unit, :mass),
          consumed_quantity: 40, consumed_unit: create(:unit, :mass),
          food: apricot),
        build(:annotation_item,
          present_quantity: 250, present_unit: create(:unit, :volume),
          consumed_quantity: 120, consumed_unit: create(:unit, :volume),
          food: nil, product: coke)
      ])
  end

  before do
    sign_in(admin)
  end

  it do # rubocop:disable RSpec/ExampleLength
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)
    expect(page).to have_css(".annotation-item", count: 2)
    expect(page).to have_text("Total consumed:\n40.0 g\n120.0 ml")

    # Add another product
    click_button("Add Product")
    expect(page).to have_css(".annotation-item", count: 3)

    # Check that newly added annotation item is selected
    last_annotation_id = AnnotationItem.last.id
    last_annotation_item_element = page.all(".annotation-item")[0]
    expect(last_annotation_item_element["data-id"]).to eq(last_annotation_id)
    expect(last_annotation_item_element[:selected]).to be_truthy

    # Enter a bad product barcode
    annotation_items = page.all(".annotation-item")
    annotation_item_1 = annotation_items[0]
    expect(page).not_to have_text("Barcode must be a valid EAN or UPC barcode")
    within(annotation_item_1) do
      expect(page).to have_field("annotation_item[barcode]")
      fill_in("annotation_item[barcode]", with: "unknown")
      expect(page).to have_field("annotation_item[consumed_quantity]")
      fill_in("annotation_item[present_quantity]", with: "30")
    end
    expect(page).to have_text("Barcode must be a valid EAN or UPC barcode")
    sleep(0.2)

    annotation_item = page.first(".annotation-item")
    within(annotation_item) do
      expect(page).to have_field("annotation_item[barcode]")
      fill_in("annotation_item[barcode]", with: mars.barcode)
      expect(page).to have_field("annotation_item[consumed_quantity]")
      fill_in("annotation_item[consumed_quantity]", with: "50")
    end
    expect(page).not_to have_text("Barcode must be a valid EAN or UPC barcode")
  end
end
