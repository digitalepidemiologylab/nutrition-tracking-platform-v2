# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Participant::Users::PasswordsController) do
  let(:token) { "reset_password_token" }
  let(:digested_token) { Devise.token_generator.digest(self, :reset_password_token, token) }

  describe "#edit" do
    it do
      get(
        edit_participant_user_password_path(locale: :fr),
        params: {reset_password_token: token}
      )
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:request) do
      patch(
        participant_user_password_path(locale: :fr),
        params: params
      )
    end

    context "with valid params" do
      let(:params) do
        {
          participant_user: {
            reset_password_token: token,
            password: "new_password",
            password_confirmation: "new_password"
          }
        }
      end

      context "when user doesn't exist" do
        it do
          request
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("Reset password token n&#39;est pas valide")
        end
      end

      context "when user exists" do
        let!(:user) do
          create(
            :user,
            :with_tokens,
            reset_password_token: digested_token,
            reset_password_sent_at: 2.minutes.ago
          )
        end

        it do
          expect { request }
            .to change { user.reload.tokens }.to({})
          expect(response).to redirect_to(root_path)
          expect(flash[:notice])
            .to eq("Votre mot de passe a été modifié avec succès.
              Veuillez ouvrir votre application mobile et vous connecter avec votre nouveau mot de passe.".squish)
        end
      end
    end

    context "with invalid params" do
      let!(:user) { create(:user, reset_password_token: digested_token, reset_password_sent_at: 2.minutes.ago) }
      let(:params) do
        {
          participant_user: {
            reset_password_token: token,
            password: "new_password",
            password_confirmation: "new_invalid_password"
          }
        }
      end

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password confirmation ne concorde pas avec Password")
      end
    end
  end
end
