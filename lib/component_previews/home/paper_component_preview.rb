# frozen_string_literal: true

class Home::PaperComponentPreview < ViewComponent::Preview
  def default
    render(Home::PaperComponent.new(
      journal: "A journal, 2022",
      title: "A title",
      authors: "Some authors",
      url: "https://www.digitalepidemiologylab.org"
    ))
  end
end
