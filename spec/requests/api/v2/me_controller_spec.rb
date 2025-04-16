# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::MeController) do
  let(:user) { create(:user) }

  describe "#show" do
    context "when anonymous visitor" do
      it do
        get api_v2_me_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in user" do
      before { api_sign_in(user) }

      it do
        get api_v2_me_path, headers: auth_params
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body))
          .to eq(
            {
              "data" => {
                "attributes" => {
                  "email" => user.reload.email,
                  "anonymous" => false,
                  "dishes_private" => true
                },
                "id" => user.id,
                "type" => "users"
              },
              "jsonapi" => {"version" => "1.0"}
            }
          )
      end
    end
  end
end
