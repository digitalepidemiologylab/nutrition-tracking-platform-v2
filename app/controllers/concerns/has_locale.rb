# frozen_string_literal: true

module HasLocale
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  def set_locale(&action)
    if request.format.json?
      set_locale_for_api(&action)
    else
      set_locale_for_html(&action)
    end
  end

  def set_locale_for_api(&action)
    locale = params[:locale] || locale_from_request_or_default

    I18n.with_locale(locale, &action)
  end

  def set_locale_for_html(&action)
    locale = params[:locale]

    if locale.blank?
      redirect_to root_path(locale: locale_from_request_or_default)
      return
    end

    I18n.with_locale(locale, &action)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  protected def locale_from_request_or_default
    locale_from_request = request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    locale_from_request&.to_sym&.in?(I18n.available_locales) ? locale_from_request : I18n.default_locale
  end
end
