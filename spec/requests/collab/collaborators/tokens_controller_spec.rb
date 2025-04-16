# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborators::TokensController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }

  before { sign_in(collaborator_admin) }

  describe "#create" do
    let(:request) { post(collab_collaborator_tokens_path(collaborator_admin), headers: turbo_stream_headers) }

    context "when successful" do
      it do
        request
        expect(response.body).to match("<turbo-stream action=\"update\"")
        expect(response.body).to match("The token has been created")
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Collaborator).to receive(:save).and_return(false)
        allow_any_instance_of(Collaborator).to receive(:errors)
          .and_return(ActiveModel::Errors.new(collaborator_admin).tap { |e| e.add(:tokens, "invalid") })
      end

      it do
        request
        expect(response.body).to match("<turbo-stream action=\"update\"")
        expect(response.body).to match("Tokens invalid")
      end
    end
  end

  describe "#destroy" do
    let(:request) { delete(collab_collaborator_token_path(collaborator_admin, client), headers: turbo_stream_headers) }

    context "when successful" do
      let(:client) do
        devise_token = collaborator_admin.create_token
        collaborator_admin.save!
        devise_token.client
      end

      it do
        request
        expect(response.body).to match("<turbo-stream action=\"update\"")
        expect(response.body).to match("The token has been deleted")
      end
    end

    context "when failed" do
      let(:client) { "invalid" }

      before do
        allow_any_instance_of(Collaborator).to receive(:save).and_return(false)
        allow_any_instance_of(Collaborator).to receive(:errors)
          .and_return(ActiveModel::Errors.new(collaborator_admin).tap { |e| e.add(:tokens, "invalid") })
      end

      it do
        request
        expect(response.body).to match("<turbo-stream action=\"update\"")
        expect(response.body).to match("Tokens invalid")
      end
    end
  end
end
