# frozen_string_literal: true

RSpec.configure do |config|
  def api_sign_in(user)
    post api_v2_user_session_path,
      params: {
        data: {
          type: "users",
          attributes: {
            email: user.email,
            password: user.password
          }
        }
      }.to_json,
      headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
  end

  def auth_params
    {
      "content-type" => "application/json",
      "accept" => "application/json",
      "access-token" => headers.fetch("access-token"),
      "client" => headers.fetch("client"),
      "uid" => headers.fetch("uid"),
      "expiry" => headers.fetch("expiry"),
      "token-type" => headers.fetch("token-type")
    }
  end

  def collab_auth_headers(collaborator)
    devise_token = collaborator.create_token
    collaborator.save!

    {
      "content-type" => "application/json",
      "accept" => "application/json",
      "access-token" => devise_token.token,
      "client" => devise_token.client,
      "uid" => collaborator.email,
      "expiry" => devise_token.expiry,
      "token-type" => "Bearer"
    }
  end

  def set_http_headers
    consumes("application/json")
    produces("application/json")
    parameter(name: "token-type", in: :header, type: :string,
      description: "Default is `Bearer` (value from the response headers of the sign in request)")
    parameter(name: "access-token", in: :header, type: :string,
      description: "Get the value from the response headers of the sign in request")
    parameter(name: :client, in: :header, type: :string,
      description: "Get the value from the response headers of the sign in request")
    parameter(name: :uid, in: :header, type: :string,
      description: "Current user email (value from the response headers of the sign in request)")

    # rubocop:disable RSpec/VariableName
    let(:"token-type") { "Bearer" }
    let(:"access-token") { headers.fetch("access-token") }
    # rubocop:enable RSpec/VariableName
    let(:client) { headers.fetch("client") }
    let(:uid) { headers.fetch("uid") }
  end
end
