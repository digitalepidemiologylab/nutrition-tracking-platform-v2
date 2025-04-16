# frozen_string_literal: true

require "rails_helper"

describe(Collab::Webauthn::CredentialsController) do
  let(:collaborator) { create(:collaborator, name: "John Doe", email: "john.doe@example.com") }

  before { sign_in(collaborator) }

  describe "#new" do
    before { get new_collab_webauthn_credential_path }

    it do
      expect(response).to have_http_status(:success)
      expect(response.body).to include("You need to add a passkey to your account before you can continue.")
    end
  end

  describe "#create" do
    let(:params) do
      {
        type: "public-key",
        id: "4SDjiDqtezIWXFXF573sna7fcR2dAwETygOnFOKb4KI",
        rawId: "4SDjiDqtezIWXFXF573sna7fcR2dAwETygOnFOKb4KI",
        authenticatorAttachment: "platform",
        response: {
          clientDataJSON: "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiQ0pJQlB5bUs3YlhDcnhsYndtOTJCSzZyYWg0Y3lXdEVrSzV5T1JvckIxVSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6MzAwMCIsImNyb3NzT3JpZ2luIjpmYWxzZX0",
          attestationObject: "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NFAAAAAK3OAAI1vMYKZIsLJfHwVQMAIOEg44g6rXsyFlxVxee97J2u33EdnQMBE8oDpxTim-CipQECAyYgASFYIFjSmyX3pUGx0f8W5RsCS3KgVZVWGMH_bYMTtCFfOhCwIlggpDHVIo3yee3DcWwgnyZHNUbKGbIkbF6cvYdbz-eVAvs",
          transports: ["internal"]
        },
        clientExtensionResults: {},
        nickname: Faker::Company.buzzword,
        locale: "en",
        credential: {
          type: "public-key",
          id: "4SDjiDqtezIWXFXF573sna7fcR2dAwETygOnFOKb4KI",
          rawId: "4SDjiDqtezIWXFXF573sna7fcR2dAwETygOnFOKb4KI",
          authenticatorAttachment: "platform",
          response: {
            clientDataJSON: "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiQ0pJQlB5bUs3YlhDcnhsYndtOTJCSzZyYWg0Y3lXdEVrSzV5T1JvckIxVSIsIm9yaWdpbiI6Imh0dHA6Ly9sb2NhbGhvc3Q6MzAwMCIsImNyb3NzT3JpZ2luIjpmYWxzZX0",
            attestationObject: "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YVikSZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2NFAAAAAK3OAAI1vMYKZIsLJfHwVQMAIOEg44g6rXsyFlxVxee97J2u33EdnQMBE8oDpxTim-CipQECAyYgASFYIFjSmyX3pUGx0f8W5RsCS3KgVZVWGMH_bYMTtCFfOhCwIlggpDHVIo3yee3DcWwgnyZHNUbKGbIkbF6cvYdbz-eVAvs",
            transports: ["internal"]
          },
          clientExtensionResults: {}
        }
      }
    end

    let(:session) {
      {
        webauthn_credential_register_challenge: collaborator.id
      }
    }

    let(:request) do
      post collab_webauthn_credentials_path, params: params, headers: turbo_stream_headers
    end

    before do
      allow_any_instance_of(described_class).to receive(:session).and_return(session)
    end

    context "when successful" do
      before do
        allow_any_instance_of(WebAuthn::PublicKeyCredentialWithAttestation).to receive(:verify).and_return(true)
      end

      it do
        request
        expect(response).to have_http_status(:success)
        expect(response.body).to match("<turbo-stream action=\"append\"")
        expect(response.body).to include("Passkey successfully created")
      end
    end

    context "when unsuccessful" do
      context "when credential cannot be saved" do
        before do
          allow_any_instance_of(WebAuthn::PublicKeyCredentialWithAttestation).to receive(:verify).and_return(true)
          allow_any_instance_of(WebauthnCredential).to receive(:save).and_return(false)
        end

        it do
          request
          expect(response).to have_http_status(:success)
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(response.body).to include("Couldn't add your Security Key")
        end
      end

      context "when verification fails" do
        before do
          allow_any_instance_of(WebAuthn::PublicKeyCredentialWithAttestation).to receive(:verify).and_raise(WebAuthn::Error, "error")
        end

        it do
          request
          expect(response).to have_http_status(:success)
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(response.body).to include("Verification failed: error")
        end
      end
    end
  end

  describe "#destroy" do
    let!(:credential) { create(:webauthn_credential, collaborator: collaborator) }
    let(:request) { delete(collab_webauthn_credential_path(credential), headers: turbo_stream_headers) }

    context "when successful" do
      it do
        expect { request }.to change { collaborator.webauthn_credentials.count }.by(-1)
        expect(response).to have_http_status(:success)
        expect(response.body).to match("<turbo-stream action=\"remove\"")
        expect(response.body).to include("Passkey successfully deleted")
      end
    end

    context "when unsuccessful" do
      before do
        allow_any_instance_of(WebauthnCredential).to receive(:destroy).and_return(false)
      end

      it do
        expect { request }.not_to change { collaborator.webauthn_credentials.count }
        expect(response).to have_http_status(:success)
        expect(response.body).not_to match("<turbo-stream action=\"remove\"")
        expect(response.body).to include("Passkey could not be deleted")
      end
    end
  end
end
