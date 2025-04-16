# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/me/passwords", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "6c14b1fc-42b5-4703-a598-e7cc591c97e3") }

  describe "password reset (send email with password reset token)" do
    path "/api/v2/me/password" do
      post("reset password") do
        tags "Passwords"
        consumes "application/json"
        produces "application/json"
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[users]},
                attributes: {
                  type: :object,
                  properties: {
                    email: {
                      default: "user_1@myfoodrepo.org",
                      description: "Email of User to sign in",
                      type: :string
                    }
                  },
                  required: %w[email]
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }
        parameter name: "accept-language",
          in: :header,
          type: :string,
          description: "Locale"

        response(202, "OK") do
          let(:data) {
            {
              data: {
                type: "users",
                attributes: {
                  email: user.email
                }
              }
            }
          }
          let(:"accept-language") { :fr } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            expect(response).to have_http_status(:accepted)
            expect(JSON.parse(response.body)).to eq(
              {
                "data" => nil,
                "meta" => {
                  "message" => "Si votre adresse électronique existe dans notre base de données, vous recevrez un lien de
                  récupération du mot de passe à votre adresse électronique dans quelques minutes.".squish
                },
                "jsonapi" => {"version" => "1.0"}
              }
            )
            expect(response.headers.keys).not_to include("access-token", "uid", "client", "token-type")
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
