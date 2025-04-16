# frozen_string_literal: true

require "rails_helper"

describe("Comment", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:annotation) { create(:annotation) }
  let(:note) { "This is a note" }
  let(:note_form_turbo_frame_selector) { "turbo-frame##{ActionView::RecordIdentifier.dom_id(annotation.dish.user, :note)}" }

  before { sign_in(admin) }

  it do
    visit(collab_annotation_path(annotation))
    page.driver.browser.manage.window.resize_to(2000, 1500)
    expect(page).to have_selector(note_form_turbo_frame_selector)
    expect(page).not_to have_selector("#{note_form_turbo_frame_selector} form")

    within(note_form_turbo_frame_selector) do
      click_link("Edit")
    end
    expect(page).to have_selector("#{note_form_turbo_frame_selector} form")

    within(note_form_turbo_frame_selector) do
      click_link("Cancel")
    end
    expect(page).not_to have_selector("#{note_form_turbo_frame_selector} form")

    within(note_form_turbo_frame_selector) do
      click_link("Edit")
    end
    fill_in("note_form_note", with: note)
    click_button("Update Note about User")
    expect(page).not_to have_selector("#{note_form_turbo_frame_selector} form")
    expect(page).to have_text(note)
  end
end
