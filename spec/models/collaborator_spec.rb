# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collaborator) do
  it_behaves_like "has_timezone"
  it_behaves_like "has_password_not_pwned"

  describe "Associations" do
    let(:collaborator) { build(:collaborator) }

    it do
      expect(collaborator).to have_many(:collaborations).inverse_of(:collaborator).dependent(:destroy)
      expect(collaborator).to have_many(:comments).inverse_of(:collaborator).dependent(:restrict_with_error)
      expect(collaborator).to have_many(:webauthn_credentials).inverse_of(:collaborator).dependent(:destroy)
    end
  end

  describe "Validations" do
    let(:collaborator) { build(:collaborator) }

    it { expect(collaborator).to be_valid }

    describe "name" do
      it { expect(collaborator).to validate_presence_of(:name) }
    end

    describe "password" do
      let(:collaborator) { build(:collaborator, password: password) }

      context "when password has been pwned", pwned_range: "5BAA6" do
        let(:password) { "password" }

        it do
          expect(collaborator).not_to be_valid
          expect(collaborator.errors.full_messages).to contain_exactly("Password has previously appeared in a data breach and should not be used")
        end
      end

      context "when password has not been pwned", pwned_range: "37D5B" do
        let(:password) { "t3hb3stpa55w0rd" }

        it { expect(collaborator).to be_valid }
      end
    end

    describe "webauthn_id" do
      it { expect(collaborator).to validate_uniqueness_of(:webauthn_id).allow_nil }
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      describe "#set_session_token" do
        let(:collaborator) { build(:collaborator, session_token: nil) }

        it { expect { collaborator.validate }.to change(collaborator, :session_token).from(nil) }
      end
    end
  end

  describe "#reset_session_token" do
    let(:collaborator) { create(:collaborator) }

    it { expect { collaborator.reset_session_token }.to change(collaborator, :session_token) }
    it { expect { collaborator.reset_session_token }.not_to change { collaborator.reload.session_token } }
  end
end
