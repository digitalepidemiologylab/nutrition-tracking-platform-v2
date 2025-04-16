# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Public::ErrorsController) do
  before { enable_error_pages }

  describe "#show" do
    context "when page requested not exists" do
      it do
        get "/not_existing_path"
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("The page you are looking for doesn&#39;t seem to exist...")
      end
    end

    context "when request raise an unprocessable entity" do
      before { allow_any_instance_of(Public::HomeController).to receive(:show).and_raise(ActiveRecord::RecordInvalid) }

      it do
        get root_path
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("The server was not able to carry out the requested instructions...")
      end
    end

    context "when request has an internal error" do
      before { allow_any_instance_of(Public::HomeController).to receive(:show).and_raise("Unknown error") }

      it do
        get root_path
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include("The server had an unexpected problem...")
      end
    end
  end
end
