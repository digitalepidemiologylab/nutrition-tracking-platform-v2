# frozen_string_literal: true

require "rails_helper"

describe Collab::Collaborators::SessionsController do
  let!(:collaborator) { create(:collaborator, session_token: "session_token") }

  describe "GET #destroy" do
    before { sign_in(collaborator) }

    it do
      expect { delete destroy_collaborator_session_path }
        .to change { collaborator.reload.session_token }.from("session_token")
    end
  end
end
