# frozen_string_literal: true

require "rails_helper"

describe(WebauthnCredential) do
  describe "Association" do
    let(:webauthn_credential) { build(:webauthn_credential) }

    it do
      expect(webauthn_credential).to belong_to(:collaborator).inverse_of(:webauthn_credentials)
    end
  end

  describe "Validations" do
    let(:webauthn_credential) { build(:webauthn_credential) }

    it { expect(webauthn_credential).to be_valid }

    describe "external_id" do
      it { expect(webauthn_credential).to validate_presence_of(:external_id) }
      it { expect(webauthn_credential).to validate_uniqueness_of(:external_id) }
    end

    describe "public_key" do
      it { expect(webauthn_credential).to validate_presence_of(:public_key) }
    end

    describe "nickname" do
      it { expect(webauthn_credential).to validate_presence_of(:nickname) }
      it { expect(webauthn_credential).to validate_uniqueness_of(:nickname).scoped_to(:collaborator_id) }
    end

    describe "sign_count" do
      it { expect(webauthn_credential).to validate_presence_of(:sign_count) }
      it { expect(webauthn_credential).to validate_numericality_of(:sign_count).only_integer.is_greater_than_or_equal_to(0) }
    end
  end
end
