# frozen_string_literal: true

require "rails_helper"

describe(Collab::Webauthn::AuthenticationsController) do
  let(:collaborator) { create(:collaborator, name: "John Doe", email: "john.doe@example.com") }

  before do
    allow_any_instance_of(described_class).to receive(:session).and_return(session)
    sign_in(collaborator)
  end

  describe "#new" do
    let(:request) do
      get(new_collab_webauthn_authentication_path)
    end

    context "when collaborator is found through session" do
      let(:session) do
        {
          webauthn_authentication: {
            "collaborator_id" => collaborator.id
          }
        }
      end

      it do
        request
        expect(response).to have_http_status(:success)
      end
    end

    context "when collaborator is not found through session" do
      let(:session) do
        {
          webauthn_authentication: {
            "collaborator_id" => "wrong_id"
          }
        }
      end

      it do
        request
        expect(response).to redirect_to(new_collaborator_session_path)
      end
    end
  end
end
