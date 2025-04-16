# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::ProductsController) do
  let(:user) { create(:user) }
  let(:body) { JSON.parse(response.body) }

  before { api_sign_in(user) }

  describe "#index" do
    let!(:product) { create(:product) }

    it do
      get api_v2_products_path, headers: auth_params
      expect(body["data"].count).to eq(1)
      expect(body["included"]).to be_nil
      expect(body["meta"]).to eq({"page" => 1, "prev" => nil, "next" => nil, "last" => 1})
    end
  end
end
