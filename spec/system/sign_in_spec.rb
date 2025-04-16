# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Sign in", :js) do
  let!(:email) { Faker::Internet.email }
  let!(:password) { "MyFoodRepoPassword3" }
  let!(:collaborator) { create(:collaborator, email: email, password: password, webauthn_credentials: []) }

  before do
    options = ::Selenium::WebDriver::VirtualAuthenticatorOptions.new(user_verification: true, user_verified: true, user_consenting: true)
    page.driver.browser.add_virtual_authenticator(options)
    page.driver.browser.manage.window.resize_to(2000, 1500)
  end

  context "when failed" do
    it do
      visit(root_path)
      click_link("Sign in")
      expect(page).to have_current_path(new_collaborator_session_path)
      fill_in("Email", with: email)
      fill_in("Password", with: "wrong_password")
      click_button("Sign in")
      expect(page).to have_current_path(new_collaborator_session_path)
      expect(page).to have_text("Invalid Email address or password.")
    end
  end

  context "when successful" do
    it do # rubocop:disable RSpec/ExampleLength
      # Sign in without existing passkey
      visit(new_collaborator_session_path)
      fill_in("Email", with: email)
      fill_in("Password", with: password)
      expect(page).to have_field("collaborator_email", with: email)
      click_button("Sign in")
      expect(page).to have_css(".flash", text: "Signed in successfully.")
      expect(page).to have_current_path(new_collab_webauthn_credential_path)
      fill_in("Passkey name", with: "USB key")
      click_button("Add Passkey")
      expect(page).to have_css(".flash", text: "Passkey successfully created")
      expect(page).to have_current_path(collab_profile_path)

      # Sign out
      click_button(collaborator.name)
      expect(page).to have_css("[data-dropdown-component-target='menu']")
      click_button("Sign out")
      expect(page).to have_text("Signed out successfully.")
      expect(page).to have_current_path(root_path)

      # Sign in with existing passkey
      click_link("Sign in")
      fill_in("Email", with: email)
      fill_in("Password", with: password)
      click_button("Sign in")
      expect(page).to have_current_path(new_collab_webauthn_authentication_path)
      expect(page).not_to have_css(".flash")
      sleep(0.5)
      click_button("Authenticate")
      expect(page).to have_css(".flash", text: "Signed in successfully.")
      expect(page).to have_current_path(collab_profile_path)
    end
  end
end
