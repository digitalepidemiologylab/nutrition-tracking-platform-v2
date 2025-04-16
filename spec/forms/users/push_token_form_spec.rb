# frozen_string_literal: true

require "rails_helper"

describe Users::PushTokenForm do
  let(:user) { create(:user) }
  let(:push_token_id) { Faker::Internet.uuid }
  let(:token) { Faker::Internet.uuid }
  let(:form) { described_class.new(user: user, params: params) }

  describe "#save" do
    context "when token doesn't exists" do
      let(:params) do
        {
          id: push_token_id,
          attributes: {
            token: token, platform: "android", locale: :fr
          }
        }
      end

      it do
        expect { form.save }.to change(PushToken, :count).by(1)
        push_token = form.push_token
        expect(push_token).to be_persisted
        expect(push_token.id).to eq(push_token_id)
        expect(push_token.token).to eq(token)
        expect(push_token.platform).to eq("android")
        expect(push_token.locale).to eq("fr")
        expect(push_token.user).to eq(user)
        expect(push_token.deactivated_at).to be_nil
      end
    end

    context "when token already exists" do
      let!(:push_token) { create(:push_token, :android, token: token, user: user, locale: :fr) }
      let(:params) do
        {
          id: nil,
          attributes: {
            token: token, platform: push_token.platform, locale: :fr
          }
        }
      end

      it do
        expect { form.save }.not_to change(PushToken, :count)
        expect(form.push_token).to eq(push_token)
      end
    end

    context "when token already exists but associated with another user" do
      let!(:push_token) { create(:push_token, :android, token: token, locale: :fr) }
      let(:params) do
        {
          id: nil,
          attributes: {
            token: token, platform: push_token.platform, locale: :fr
          }
        }
      end

      it do
        expect { form.save }
          .to change(PushToken, :count).by(1)
          .and(change { push_token.reload.deactivated_at }.from(nil))
        expect(form.push_token).not_to eq(push_token)
      end
    end
  end
end
