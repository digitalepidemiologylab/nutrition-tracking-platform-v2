# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::Users::SessionsController) do
  let(:user) { create(:user, password: "password") }

  describe "new sign in" do
    before do
      get(
        new_api_v2_user_session_path,
        headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
      )
    end

    it do
      expect(response).to have_http_status(:method_not_allowed)
      expect(JSON.parse(response.body)).to eq(
        "errors" => [
          {"detail" => "Use POST /sign_in to sign in. GET is not supported."}
        ],
        "jsonapi" => {"version" => "1.0"}
      )
    end
  end

  describe "sign in" do
    let(:params) {
      {
        data: {
          type: "users",
          attributes: {
            email: user.email,
            password: password
          }
        }
      }
    }

    before do
      post(
        api_v2_user_session_path,
        params: params.to_json,
        headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
      )
    end

    context "with valid credentials" do
      let(:password) { "password" }

      it do
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(
          "data" => {
            "type" => "users",
            "id" => user.reload.id,
            "attributes" => {
              "email" => user.email,
              "anonymous" => false,
              "dishes_private" => true
            }
          },
          "jsonapi" => {"version" => "1.0"}
        )
        expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
      end
    end

    context "with invalid credentials" do
      let!(:password) { "invalid_password" }

      it do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {"detail" => "Invalid login credentials. Please try again."}
            ],
            "jsonapi" => {"version" => "1.0"}
          )
      end
    end
  end

  describe "sign out" do
    context "when not previously signed in" do
      it do
        delete destroy_api_v2_user_session_path, headers: {}

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq(
          "errors" => [
            {"detail" => "User was not found or was not logged in."}
          ],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end

    context "when signed in" do
      it do
        api_sign_in(user)
        delete destroy_api_v2_user_session_path, headers: auth_params

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to be_empty
      end
    end
  end
end
