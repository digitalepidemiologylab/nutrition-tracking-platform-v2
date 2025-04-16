# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Public::StaticPagesController) do
  describe "#terms" do
    it do
      get terms_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#privacy" do
    it do
      get privacy_path
      expect(response).to have_http_status(:success)
    end
  end
end
