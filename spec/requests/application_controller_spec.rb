# frozen_string_literal: true

require "rails_helper"

describe(ApplicationController) do
  describe "basic auth" do
    context "when no ENV['HTTP_AUTH_USERNAME'] is set" do
      it do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when ENV['HTTP_AUTH_USERNAME'] is set" do
      before do
        ENV["HTTP_AUTH_USERNAME"] = "username"
        ENV["HTTP_AUTH_PASSWORD"] = "password"
      end

      after do
        ENV.delete("HTTP_AUTH_USERNAME")
        ENV.delete("HTTP_AUTH_PASSWORD")
      end

      it do
        get root_path
        expect(response).to have_http_status(:unauthorized)
      end

      it do
        get(
          root_path,
          params: nil,
          headers: {
            HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials("username", "password")
          }
        )
        expect(response).to have_http_status(:success)
      end
    end
  end
end
