# frozen_string_literal: true

RSpec.configure do |config|
  def fill_tom_select(locator, with:)
    select_element = page.find(locator)
    container = select_element.find(:xpath, "..")

    within(container) do
      input = find(".ts-dropdown input")
      input.send_keys(with)
      sleep(0.5) # wait filtering to happen
      first(".ts-dropdown .ts-dropdown-content .option").click
    end
  end
end
