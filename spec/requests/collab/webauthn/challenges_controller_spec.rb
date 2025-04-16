# frozen_string_literal: true

require "rails_helper"

describe(Collab::Webauthn::ChallengesController) do
  let(:collaborator) { create(:collaborator, name: "John Doe", email: "john.doe@example.com") }

  before { sign_in(collaborator) }

  describe "#create" do
    let(:request) { post collab_webauthn_challenge_path }

    context "when successful" do
      it do
        request
        expect(session[:webauthn_credential_register_challenge]).to be_present
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).keys).to contain_exactly("excludeCredentials", "extensions", "pubKeyCredParams", "rp", "timeout", "user", "challenge")
      end
    end
  end
end
