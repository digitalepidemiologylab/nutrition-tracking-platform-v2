# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::PushTokensController) do
  let(:user) { create(:user) }
  let(:token) { Faker::Crypto.sha256 }
  let(:locale) { I18n.available_locales.sample.to_s }
  let(:platform) { "android" }
  let(:params) {
    {
      data: {
        type: "push_tokens",
        attributes: {
          platform: platform,
          token: token,
          locale: locale
        }
      }
    }
  }

  before do
    api_sign_in(user)
  end

  describe "#create" do
    context "when successful" do
      it do
        expect { post api_v2_push_tokens_path, params: params.to_json, headers: auth_params }
          .to change { user.push_tokens.count }.by(1)

        json_data = JSON.parse(response.body)["data"]
        expect(json_data.keys).to contain_exactly("id", "type", "attributes", "relationships")
        expect(json_data.dig("attributes", "platform")).to eq(platform)
        expect(json_data.dig("attributes", "token")).to eq(token)
        expect(json_data.dig("attributes", "locale")).to eq(locale)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(PushToken)
          .to receive(:invalid?).and_raise(ActiveRecord::RecordNotUnique)
      end

      it do
        post api_v2_push_tokens_path, params: params.to_json, headers: auth_params
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {
                "code" => "record_not_unique", "detail" => "Record not unique", "title" => "ActiveRecord::RecordNotUnique"
              }
            ],
            "jsonapi" => {
              "version" => "1.0"
            }
          )
      end
    end
  end
end
