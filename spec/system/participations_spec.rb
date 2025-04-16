# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Add participations", :js) do
  let!(:manager_collaboration) { create(:collaboration, :manager) }
  let!(:manager) { manager_collaboration.collaborator }
  let!(:cohort) { manager_collaboration.cohort }
  let!(:participation) { create(:participation, cohort: cohort) }

  before { sign_in(manager) }

  it do # rubocop:disable RSpec/ExampleLength
    visit(collab_cohort_path(cohort))
    page.driver.browser.manage.window.resize_to(1200, 1500)
    within("##{ActionView::RecordIdentifier.dom_id(cohort, :participations)}") do
      expect(page).to have_css("tbody tr", count: 1)
      expect(page).to have_css("td", text: participation.key)
      expect(page).to have_css("td", text: "reset")

      click_link("reset")
      sleep(0.2)
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to eq("Are you sure?")

      alert.accept
      expect(page).not_to have_css("td", text: "reset")

      fill_in("participations_create_form_number", with: 2)
      click_button("Create Participations")
      sleep(0.2)
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to eq("Are you sure?")

      alert.accept
      expect(page).to have_css("tbody tr", count: 3)
    end

    expect(page).to have_css("#flash_messages", text: "Participations created successfully")
  end
end
