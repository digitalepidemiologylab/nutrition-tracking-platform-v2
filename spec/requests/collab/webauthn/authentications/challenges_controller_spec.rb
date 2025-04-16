# frozen_string_literal: true

require "rails_helper"

describe(Collab::Webauthn::Authentications::ChallengesController) do
  let(:collaborator) { create(:collaborator, name: "John Doe", email: "john.doe@example.com") }

  before do
    allow_any_instance_of(described_class).to receive(:session).and_return(session)
    allow_any_instance_of(WebAuthn::PublicKeyCredentialWithAttestation).to receive(:verify).and_return(true)
    sign_in(collaborator)
  end

  describe "#create" do
    let(:request) { post collab_webauthn_authentications_challenge_path(format: :json) }

    context "when successful" do
      let(:session) do
        {webauthn_authentication: {"collaborator_id" => collaborator.id}}
      end

      it do
        request
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).keys).to contain_exactly("allowCredentials", "challenge", "extensions", "timeout")
      end
    end

    context "when failed" do
      let(:session) do
        {webauthn_authentication: {"collaborator_id" => "wrong_id"}}
      end

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body).keys).to contain_exactly("message")
        expect(JSON.parse(response.body)["message"]).to eq(I18n.t("collab.webauthn.authentications.challenges.create.failure"))
      end
    end
  end
end
