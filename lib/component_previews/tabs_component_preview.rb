# frozen_string_literal: true

class TabsComponentPreview < ViewComponent::Preview
  def default
    render(TabsComponent.new) do |tc|
      3.times do |i|
        tc.with_tab(url: "#") { "Tab name #{i}" }
      end
      tc.with_tab(url: "#", selected: true) { "Tab name selected" }
    end
  end
end
