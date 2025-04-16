# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::Users::PasswordsController) do
  describe "#create" do
    let(:user) { create(:user, email: "user@myfoodrepo.org") }
    let(:params) {
      {
        data: {
          type: "users",
          attributes: {
            email: email
          }
        }
      }
    }

    let(:request) do
      post(
        api_v2_user_password_path,
        params: params.to_json,
        headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
      )
    end

    context "when email param is valid" do
      let(:email) { user.email }

      it do
        expect { request }
          .to change { user.reload.reset_password_sent_at }.from(nil)
          .and(change { user.reload.reset_password_token }.from(nil))
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(
          "data" => nil,
          "meta" => {"message" => "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."},
          "jsonapi" => {"version" => "1.0"}
        )
        expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
      end
    end

    context "when email param is invalid" do
      let(:email) { "invalid@myfoodrepo.org" }

      it "still respond with success, thanks to Devise paranoid mode" do
        expect { request }
          .to not_change { user.reload.reset_password_sent_at }.from(nil)
          .and(not_change { user.reload.reset_password_token }.from(nil))
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(
          "data" => nil,
          "meta" => {"message" => "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."},
          "jsonapi" => {"version" => "1.0"}
        )
        expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
      end
    end

    context "when resource has errors" do
      let(:email) { user.email }

      before do
        allow_any_instance_of(User).to receive(:errors)
          .and_return(ActiveModel::Errors.new(user).tap { |e| e.add(:base, "I've errors!") })
        request
      end

      it do
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(
          "errors" => [{"detail" => "I've errors!", "source" => {}, "title" => "Invalid base"}],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end
  end
end
