# frozen_string_literal: true

require "rails_helper"

RSpec.describe(DropdownComponent) do
  it "renders the component" do
    render_inline(described_class.new(size: :small, origin: :right)) do |c|
      c.with_icon(:globe, classes: "mr-2 text-xl text-gray-400")
      I18n.available_locales.map do |locale|
        c.with_item(text: I18n.t("dropdown_language_component.language_name", locale: locale),
          url: root_path, active: I18n.locale == locale)
      end
      c.with_item(text: "Sign out", url: destroy_collaborator_session_path, method: :delete)
      c.with_text { I18n.locale.to_s.upcase }
    end

    expect(page).to have_button("EN")
    expect(page).to have_link("English")
    expect(page).to have_link("Français")
    expect(page).to have_link("Deutsch")
    expect(page).to have_button("Sign out")
  end

  describe "Validations" do
    describe "size" do
      it do
        expect { render_inline(described_class.new(size: :md)) }
          .to raise_error(ApplicationComponent::InvalidArgumentError, "Size argument must be in small, large")
      end
    end

    describe "origin" do
      it do
        expect { render_inline(described_class.new(origin: :top)) }
          .to raise_error(ApplicationComponent::InvalidArgumentError, "Origin argument must be in right, left")
      end
    end
  end
end
