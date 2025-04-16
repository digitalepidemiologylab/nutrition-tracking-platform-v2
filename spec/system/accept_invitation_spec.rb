# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Accept invitation", :js) do
  let(:new_collaborator) { Collaborator.invite!({email: "new_collaborator@myfoodrepo.org"}) }
  let(:password) { "password" }
  let(:accept_invitation_path) do
    accept_collaborator_invitation_path(invitation_token: new_collaborator.raw_invitation_token)
  end

  before do
    options = ::Selenium::WebDriver::VirtualAuthenticatorOptions.new(user_verification: true, user_verified: true, user_consenting: true)
    page.driver.browser.add_virtual_authenticator(options)
  end

  context "when password and password confirmation don't match" do
    it do
      visit(accept_invitation_path)
      expect(page).to have_field("Email address", with: new_collaborator.email, disabled: true)
      fill_in("Name", with: "A Name")
      fill_in("Password", with: password)
      fill_in("Password confirmation", with: "wrong_password")
      click_button("Continue")
      expect(page).to have_current_path(collaborator_invitation_path)
      expect(page).to have_text("Password confirmation does not match the password")
    end
  end

  context "when password and password confirmation match" do
    it do
      visit(accept_invitation_path)
      expect(page).to have_field("Email address", with: new_collaborator.email, disabled: true)
      fill_in("Name", with: "A Name")
      fill_in("Password", with: password)
      fill_in("Password confirmation", with: password)
      click_button("Continue")
      expect(page).to have_current_path(new_collab_webauthn_credential_path)
      expect(page).to have_css(".flash", text: "Your password was set successfully. You are now signed in.")
      fill_in("Passkey name", with: "USB key")
      click_button("Add Passkey")
      expect(page).to have_css(".flash", text: "Passkey successfully created")
      expect(page).to have_current_path(collab_profile_path)
    end
  end
end
