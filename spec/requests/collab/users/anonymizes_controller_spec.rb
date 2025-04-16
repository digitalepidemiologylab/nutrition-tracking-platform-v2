# frozen_string_literal: true

require "rails_helper"

describe(Collab::Users::AnonymizesController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:user) { create(:user) }

  before { sign_in(collaborator) }

  describe "#update" do
    let(:request) { patch(collab_user_anonymizes_path(user)) }

    context "when successful" do
      it do
        expect { request }.to change { user.reload.anonymous }.from(false).to(true)
        expect(response).to redirect_to(collab_user_path(user))
        expect(flash[:notice]).to eq("User anonymized successfully")
      end
    end

    context "when unsuccessful" do
      before do
        allow_any_instance_of(User).to receive(:save!).and_raise(StandardError, "Error message")
      end

      it do
        expect { request }.not_to change { user.reload.anonymous }
        expect(response).to redirect_to(collab_user_path(user))
        expect(flash[:alert]).to eq("User could not be anonymized: Error message")
      end
    end
  end
end
