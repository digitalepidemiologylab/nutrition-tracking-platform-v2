# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Filter Users", :js) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:user) { build(:user, email: "john.doe@myfoodrepo.org") }

  before do
    create_list(:user, 10)
    user.save
    sign_in(admin)
  end

  it do
    visit(collab_users_path)
    page.driver.browser.manage.window.resize_to(1200, 1500)
    expect(page).to have_css("#query")
    expect(page).to have_css("#users tbody tr", minimum: 10)
    fill_in("Search", with: "john.do")
    expect(page).to have_css("#users tbody tr", count: 1)
    expect(page).to have_css("#users tbody tr", text: user.email)
  end
end
