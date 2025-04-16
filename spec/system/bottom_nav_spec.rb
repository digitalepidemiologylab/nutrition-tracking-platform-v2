# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Bottom nav", :js) do
  let!(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  it do
    visit(collab_profile_path)
    page.driver.browser.manage.window.resize_to(2000, 1500)
    expect(page).not_to have_css("[data-controller='bottom-nav-component'] nav")
    click_button("More")
    expect(page).to have_css("[data-controller='bottom-nav-component'] nav")
    click_button("More")
    expect(page).not_to have_css("[data-controller='bottom-nav-component'] nav")
  end
end
