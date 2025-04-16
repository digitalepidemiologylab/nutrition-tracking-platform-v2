# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::DirectUploadsController) do
  let(:user) { create(:user) }
  let(:dish_form) { build(:dish_form, user: user) }
  let(:params) {
    {
      data: {
        type: "direct_uploads",
        attributes: {
          filename: "test.jpg",
          byte_size: 1234,
          checksum: "checksum",
          content_type: "image/jpeg"
        }
      }
    }.to_json
  }

  describe "#create" do
    context "when signed_in" do
      before { api_sign_in(user) }

      context "when successful" do
        it do
          post api_v2_direct_uploads_path, params: params, headers: auth_params
          expect(response).to have_http_status(:ok)

          json = JSON.parse(response.body)
          json_data = json["data"]
          expect(json_data.keys).to contain_exactly("id", "type", "attributes")
          expect(json_data["attributes"].keys).to contain_exactly("url", "headers")
        end
      end

      context "when failed" do
        before do
          allow(ActiveStorage::Blob).to receive(:create_before_direct_upload!).and_raise(ActiveStorage::Error)
        end

        it do
          post api_v2_direct_uploads_path, params: {}, headers: auth_params
          expect(JSON.parse(response.body))
            .to eq(
              {
                "errors" => [
                  {
                    "detail" => "Internal server error",
                    "title" => "ArgumentError"
                  }
                ],
                "jsonapi" => {
                  "version" => "1.0"
                }
              }
            )
        end
      end
    end

    context "when unauthorized" do
      it do
        post api_v2_direct_uploads_path, params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
