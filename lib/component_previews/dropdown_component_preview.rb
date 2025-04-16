# frozen_string_literal: true

class DropdownComponentPreview < ViewComponent::Preview
  def default
    render(DropdownComponent.new(size: :small, origin: :right)) do |c|
      c.with_icon(:globe, classes: "mr-2 text-xl text-gray-400")
      I18n.available_locales.map do |locale|
        c.with_item(text: I18n.t("dropdown_language_component.language_name", locale: locale),
          url: {locale: locale}, active: I18n.locale == locale)
      end
      c.with_text { I18n.locale.to_s.upcase }
    end
  end
end
