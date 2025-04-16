# frozen_string_literal: true

require "rails_helper"

RSpec.describe("CommentTemplate", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let(:dish) { create(:dish, :with_dish_image) }
  let!(:annotation) { create(:annotation, :annotatable, dish: dish) }

  let(:comment_template_1_title) { "Comment template title 1" }
  let(:comment_template_1_message) { "Comment template message 1" }
  let!(:comment_template_1) { create(:comment_template, :valid, title: comment_template_1_title, message: comment_template_1_message) }

  let(:comment_template_2_title) { "Comment template title 2" }
  let(:comment_template_2_message) { "Comment template message 2" }
  let!(:comment_template_2) { create(:comment_template, :valid, title: comment_template_2_title, message: comment_template_2_message) }

  let(:comments_turbo_frame_selector) { "turbo-frame#comments_dish_#{dish.id}" }

  before { sign_in(admin) }

  it do
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)

    textarea = page.find("textarea[name='comment[message]']")
    expect(textarea.value).to be_blank

    select(comment_template_1_title, from: "comment_template")
    page.execute_script("window.scrollBy(0,5000)")
    expect(textarea.value).to eq(comment_template_1_message)

    select(comment_template_2_title, from: "comment_template")
    expect(textarea.value).to eq([comment_template_1_message, comment_template_2_message].join("\n"))
  end
end
