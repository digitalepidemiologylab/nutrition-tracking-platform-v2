# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::Users::RegistrationsController) do
  describe "#create" do
    let(:params) {
      {
        data: {
          type: "participations",
          attributes: {
            key: participation.key
          }
        }
      }
    }

    let(:request) do
      post(
        api_v2_me_path,
        params: params.to_json,
        headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
      )
    end

    context "when successful" do
      context "when sign up of anonymous user (participation not associated with user)" do
        let!(:participation) { create(:participation, :not_associated) }

        it do
          expect { request }.to change(User, :count).by(1).and(change { participation.reload.user_id }.from(nil))
          expect(response).to have_http_status(:success)
          user = User.last
          expect(JSON.parse(response.body))
            .to eq(
              {
                data: {
                  attributes: {
                    email: "#{user.id}@#{User::ANONYMOUS_DOMAIN}",
                    dishes_private: true,
                    anonymous: true
                  },
                  id: user.id,
                  type: "users"
                },
                jsonapi: {version: "1.0"}
              }.as_json
            )
          expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
        end
      end

      context "when sign in of user (participation already associated with user)" do
        let!(:participation) { create(:participation, :nil_associated_at) }
        let(:user) { participation.user }

        it do
          request
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body))
            .to eq(
              {
                data: {
                  attributes: {
                    email: user.email,
                    dishes_private: true,
                    anonymous: false
                  },
                  id: user.id,
                  type: "users"
                },
                jsonapi: {version: "1.0"}
              }.as_json
            )
          expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
        end
      end
    end

    context "when failed" do
      let!(:participation) { create(:participation) }

      it do
        expect { request }
          .to not_change(User, :count)
          .and(not_change { participation.reload.user_id }.from(participation.user_id))
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {
                "detail" => "Participation is not available",
                "source" => {},
                "title" => "Invalid participation"
              }
            ],
            "jsonapi" => {"version" => "1.0"}
          )
        expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
      end
    end

    context "when user is already signed in" do
      let!(:user) { create(:user, password: "password") }
      let!(:participation) { create(:participation, :not_associated) }

      let(:request) do
        post(
          api_v2_me_path,
          params: params.to_json,
          headers: {"Content-Type" => "application/json", "Accept" => "application/json"}.merge(auth_params)
        )
      end

      before { api_sign_in(user) }

      it do
        expect { request }
          .to not_change(User, :count)
          .and(not_change { participation.reload.user_id }.from(participation.user_id))
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [{"detail" => "You are already signed in."}],
            "jsonapi" => {"version" => "1.0"}
          )
        expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
      end
    end
  end

  describe "#update" do
    let(:user) { create(:user, :anonymous) }
    let(:new_password) { "a_new_password" }
    let(:new_email) { "new_email@myfoodrepo.org" }
    let(:params) {
      {
        data: {
          type: "users",
          attributes: {
            email: new_email,
            password: new_password,
            password_confirmation: new_password,
            dishes_private: false
          }
        }
      }
    }

    let(:request) do
      patch(
        api_v2_me_path,
        params: params.to_json,
        headers: auth_params
      )
    end

    context "when user signed in" do
      before { api_sign_in(user) }

      context "when successful" do
        it do
          expect { request }
            .to change { user.reload.anonymous }.from(true).to(false)
            .and(change { user.reload.email }.to(new_email))
            .and(change { user.reload.encrypted_password })
            .and(change { user.reload.dishes_private }.from(true).to(false))
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)).to eq(
            "data" => {
              "type" => "users",
              "id" => user.reload.id,
              "attributes" => {
                "email" => user.email,
                "dishes_private" => false,
                "anonymous" => false
              }
            },
            "jsonapi" => {"version" => "1.0"}
          )
          expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
        end
      end

      context "when failed" do
        context "with validation error" do
          let(:new_password) { "a_new_password" }
          let(:existing_email) { "existing_email@myfoodrepo.org" }

          let(:params) {
            {
              data: {
                type: "users",
                attributes: {
                  email: existing_email,
                  password: new_password,
                  password_confirmation: new_password
                }
              }
            }
          }

          let(:request) do
            patch(
              api_v2_me_path,
              params: params.to_json,
              headers: auth_params
            )
          end

          before { create(:user, email: existing_email) }

          it do
            expect { request }
              .to not_change { user.reload.anonymous }.from(true)
              .and(not_change { user.reload.email })
              .and(not_change { user.reload.encrypted_password })
              .and(not_change { user.reload.dishes_private }.from(true))
            expect(JSON.parse(response.body))
              .to eq(
                "errors" => [
                  {
                    "detail" => "User: email has already been taken",
                    "source" => {},
                    "title" => "Invalid base"
                  }
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
          end
        end

        context "with exception" do
          before do
            allow_any_instance_of(Users::UpdateService).to receive(:call).and_raise(ActiveRecord::RecordNotUnique, "PG::UniqueViolation: ERROR:  duplicate key value")
          end

          it do
            expect { request }
              .to not_change { user.reload.anonymous }.from(true)
              .and(not_change { user.reload.email })
              .and(not_change { user.reload.encrypted_password })
              .and(not_change { user.reload.dishes_private }.from(true))
            expect(JSON.parse(response.body))
              .to eq(
                "errors" => [
                  {
                    "detail" => "PG::UniqueViolation: ERROR:  duplicate key value", "title" => "ActiveRecord::RecordNotUnique"
                  }
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
          end
        end
      end
    end

    context "when user is not signed in" do
      let(:request) do
        patch(
          api_v2_me_path,
          params: params.to_json
        )
      end

      it do
        expect { request }
          .to not_change { user.reload.anonymous }.from(true)
          .and(not_change { user.reload.email })
          .and(not_change { user.reload.encrypted_password })
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {"detail" => "User not found."}
            ],
            "jsonapi" => {"version" => "1.0"}
          )
        expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
      end
    end
  end

  describe "#destroy" do
    let(:user) { create(:user) }

    before { api_sign_in(user) }

    context "when successful" do
      before { delete api_v2_me_path, headers: auth_params }

      it do
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(
          "data" => nil,
          "meta" => {
            "message" => "Your personal data has been deleted. " \
              "Please note that all your dish images have been collected on behalf of a cohort. " \
              "You must contact the cohort if you want your images and their associated data to be deleted."
          },
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(::Users::AnonymizeService).to receive(:call).and_raise("Unknown error")
        delete api_v2_me_path, headers: auth_params
      end

      it do
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq(
          "errors" => [
            {"detail" => "Unable to locate account for destruction."}
          ],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end
  end
end
