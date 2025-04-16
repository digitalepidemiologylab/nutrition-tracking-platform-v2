# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Lookbook::ApplicationController) do
  before { enable_error_pages }

  context "when anonymous visitor" do
    it do
      get lookbook_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when signed in collaborator" do
    let(:collaborator) { create(:collaborator) }

    before { sign_in(collaborator) }

    it do
      get lookbook_path
      expect(response).to have_http_status(:success)
    end
  end
end
