# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Reorder annotation items", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:participation) { create(:participation) }
  let!(:food_list) { participation.cohort.food_lists.first }
  let!(:dish) { create(:dish, user: participation.user) }

  let(:food) { create(:food, food_list: food_list) }
  let!(:annotation) { create(:annotation, :with_annotation_items, participation: participation, dish: dish) }
  let!(:annotation_item_1) { annotation.annotation_items.first }
  let!(:annotation_item_2) { annotation.annotation_items.second }
  let!(:annotation_item_3) { create(:annotation_item, annotation: annotation, food: food) }

  before do
    sign_in(admin)
  end

  it do
    page.driver.browser.manage.window.resize_to(2000, 1500)
    visit(collab_annotation_path(annotation))
    expect(annotation_item_1.reload.position).to eq(1)
    expect(annotation_item_2.reload.position).to eq(2)
    annotation_item_1_element = page.find("div[data-id='#{annotation_item_1.id}']")
    annotation_item_2_element = page.find("div[data-id='#{annotation_item_2.id}']")
    annotation_item_1_element.drag_to(annotation_item_2_element)
    expect(page).to have_css("#flash_messages", text: "Successfully reordered items")
    expect(annotation_item_1.reload.position).to eq(2)
  end
end
