# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Mobile sidebar", :js) do
  let!(:collaborator) { create(:collaborator) }

  before { sign_in(collaborator) }

  it do
    visit(collab_profile_path)
    page.driver.browser.manage.window.resize_to(414, 896) # iPhone XR screen size
    expect(page).not_to have_css("[data-controller='sidebar-component']")
    click_button("Open sidebar")
    expect(page).to have_css("[data-controller='sidebar-component']")
    click_button("Close sidebar")
    expect(page).not_to have_css("[data-controller='sidebar-component']")
  end
end
