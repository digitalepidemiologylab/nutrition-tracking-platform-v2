# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ProductsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:product) { create(:product) }

  before { sign_in(collaborator) }

  describe "GET /index" do
    context "without pagination params" do
      it do
        get collab_products_path
        expect(response).to have_http_status(:success)
      end
    end

    context "with pagination params" do
      context "when valid" do
        before { get collab_products_path, params: {page: 1} }

        it { expect(response).to have_http_status(:ok) }
      end

      context "when invalid" do
        let(:params) { {page: 3} }

        it do
          get(collab_products_path, params: {page: 3})
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "GET /show" do
    it do
      get collab_product_path(product)
      expect(response).to have_http_status(:success)
    end
  end
end
