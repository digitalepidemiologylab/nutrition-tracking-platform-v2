# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Food Set select", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:food) { create(:food, :editable) }
  let(:food_set) { build(:food_set, name: "pizza napoli") }

  before do
    create_list(:food_set, 12)
    food_set.save
    sign_in(admin)
  end

  it do
    visit(edit_collab_food_path(food))
    page.driver.browser.manage.window.resize_to(1200, 1500)
    expect(page).to have_css(".ts-control")
    page.find(".ts-control").click
    expect(page).to have_css("div.option", minimum: 12)
    fill_tom_select("[name='food[food_set_ids][]']", with: "pi nap")
    select = page.find("select[name='food[food_set_ids][]']", visible: false)
    expect(select.value).to eq([food_set.id])
  end
end
