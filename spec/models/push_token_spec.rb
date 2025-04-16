# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PushToken) do
  describe "Enums" do
    describe "platform" do
      it do
        expect(build(:push_token)).to define_enum_for(:platform)
          .with_values(android: "android", ios: "ios")
          .backed_by_column_of_type(:enum)
      end
    end
  end

  describe "Associations" do
    let(:push_token) { build(:push_token) }

    it do
      expect(push_token).to belong_to(:user).inverse_of(:push_tokens)
      expect(push_token).to have_many(:push_notifications).inverse_of(:push_token).dependent(:nullify)
    end
  end

  describe "Validations" do
    let(:push_token) { build(:push_token) }

    it { expect(push_token).to be_valid }

    describe "platform" do
      context "when valid" do
        before { push_token.platform = "android" }

        it { expect(push_token).to be_valid }
      end

      context "when invalid" do
        let(:platform) { "invalid" }

        it do
          expect { push_token.platform = "invalid" }.to raise_error(ArgumentError, "'invalid' is not a valid platform")
        end
      end
    end

    describe "token" do
      let!(:push_token_deactivated) { build(:push_token, :deactivated) }

      it do
        expect(push_token).to be_valid
        expect(push_token_deactivated).to be_valid
        expect(push_token).to validate_uniqueness_of(:token).case_insensitive
        expect(push_token_deactivated).not_to validate_uniqueness_of(:token)
      end

      context "when pre-existing token" do
        before { create(:push_token, token: push_token.token) }

        it do
          expect(push_token).not_to be_valid
          expect(push_token.errors[:token]).to eq(["has already been taken"])
        end
      end
    end

    describe "locale" do
      it { expect(push_token).to validate_presence_of(:locale) }
      it { expect(push_token).to validate_inclusion_of(:locale).in_array(I18n.available_locales.map(&:to_s)) }
    end
  end

  describe "Scopes" do
    describe ".active" do
      let!(:push_token) { create(:push_token) }
      let!(:push_token_deactivated) { create(:push_token, :deactivated) }

      it { expect(described_class.active).to contain_exactly(push_token) }
    end
  end

  describe "#platform_ios?, #platform_android?" do
    let(:push_token_ios) { build(:push_token, :ios) }
    let(:push_token_android) { build(:push_token, :android) }

    it { expect(push_token_ios).to be_platform_ios }
    it { expect(push_token_android).not_to be_platform_ios }
    it { expect(push_token_android).to be_platform_android }
    it { expect(push_token_ios).not_to be_platform_android }
  end

  describe "#deactivate", :freeze_time do
    let(:push_token) { create(:push_token) }

    it do
      expect { push_token.deactivate }
        .to change { push_token.reload.deactivated_at }.from(nil).to(Time.current)
    end
  end

  describe "#deactivate!", :freeze_time do
    let(:push_token) { create(:push_token) }

    it do
      allow(push_token).to receive(:update!).and_call_original
      push_token.deactivate!
      expect(push_token).to have_received(:update!).with(deactivated_at: Time.current)
    end
  end

  describe "#deactivated?" do
    let(:push_token) { create(:push_token) }

    context "when deactivated_at is nil" do
      it { expect(push_token).not_to be_deactivated }
    end

    context "when deactivated_at is set" do
      before { push_token.deactivate }

      it { expect(push_token).to be_deactivated }
    end
  end
end
