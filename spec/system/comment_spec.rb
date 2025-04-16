# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Comment", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:dish) { create(:dish, :with_dish_image) }
  let!(:annotation) { create(:annotation, :annotatable, dish: dish) }
  let(:comments_turbo_frame_selector) { "turbo-frame#comments_annotation_#{annotation.id}" }

  before { sign_in(admin) }

  it do
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)

    expect(page).to have_selector("#{comments_turbo_frame_selector}2>div", count: 0)

    fill_in("Message", with: "This is a first comment")
    click_button("Comment")

    expect(page).to have_selector("#{comments_turbo_frame_selector}>div", count: 1)

    fill_in("Message", with: "This is a second comment")
    click_button("Comment")

    expect(page).to have_selector("#{comments_turbo_frame_selector}>div", count: 2)

    comments = page.all("#{comments_turbo_frame_selector}>div")
    expect(comments.first).to have_content("This is a first comment")
    expect(comments.last).to have_content("This is a second comment")
  end
end
