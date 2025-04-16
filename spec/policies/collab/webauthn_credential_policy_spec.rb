# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::WebauthnCredentialPolicy) do
  let!(:admin) { create(:collaborator, :admin) }
  let!(:collaborator_1) { create(:collaborator) }
  let!(:collaborator_2) { create(:collaborator) }
  let!(:webauthn_credential_admin) { admin.webauthn_credentials.sole }
  let!(:webauthn_credential_collaborator_1) { collaborator_1.webauthn_credentials.sole }
  let!(:webauthn_credential_collaborator_2) { collaborator_2.webauthn_credentials.sole }

  permissions :new?, :create? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(collaborator_1)
    end
  end

  permissions :destroy? do
    it do
      expect(described_class).to permit(admin, webauthn_credential_collaborator_1)
      expect(described_class).to permit(admin, webauthn_credential_collaborator_2)

      expect(described_class).to permit(collaborator_1, webauthn_credential_collaborator_1)
      expect(described_class).not_to permit(collaborator_1, webauthn_credential_collaborator_2)
    end
  end

  describe Collab::WebauthnCredentialPolicy::Scope do
    describe "#resolve" do
      context "when admin" do
        it do
          expect(described_class.new(admin, WebauthnCredential).resolve)
            .to contain_exactly(webauthn_credential_collaborator_1, webauthn_credential_collaborator_2, webauthn_credential_admin)
        end
      end

      context "when collaborator" do
        it do
          expect(described_class.new(collaborator_1, WebauthnCredential).resolve)
            .to contain_exactly(webauthn_credential_collaborator_1)
        end
      end
    end
  end
end
