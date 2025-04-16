# frozen_string_literal: true

require "rails_helper"

RSpec.describe("LocaleRedirection") do
  context "when the browser doesn't provide the HTTP_ACCEPT_LANGUAGE header" do
    context "when the locale is missing" do
      before { get root_path(locale: nil) }

      it { expect(response).to redirect_to(root_path(locale: I18n.default_locale)) }
    end

    context "when the locale is present" do
      before { get root_path(locale: :fr) }

      it { expect(response).to be_successful }
    end
  end

  context "when the browser provide the HTTP_ACCEPT_LANGUAGE header" do
    before { get root_path(locale: nil), headers: {"HTTP_ACCEPT_LANGUAGE" => http_accept_language} }

    context "when HTTP_ACCEPT_LANGUAGE is fr" do
      let(:http_accept_language) { "fr" }

      it { expect(response).to redirect_to(root_path(locale: "fr")) }
    end

    context "when HTTP_ACCEPT_LANGUAGE is de-CH" do
      let(:http_accept_language) { "de-CH" }

      it { expect(response).to redirect_to(root_path(locale: "de")) }
    end

    context "when HTTP_ACCEPT_LANGUAGE is fr-CH,en;q=0.5" do
      let(:http_accept_language) { "fr-CH,en;q=0.5" }

      it { expect(response).to redirect_to(root_path(locale: "fr")) }
    end

    context "when HTTP_ACCEPT_LANGUAGE is ru" do
      let(:http_accept_language) { "ru" }

      it { expect(response).to redirect_to(root_path(locale: I18n.default_locale)) }
    end
  end
end
