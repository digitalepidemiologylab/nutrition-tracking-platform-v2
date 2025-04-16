# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CommentsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:annotation) { create(:annotation) }
  let(:user_comment) { create(:comment, annotation: annotation) }
  let(:collaborator_comment) { create(:comment, :from_collaborator, annotation: annotation) }

  before { sign_in(collaborator) }

  describe "GET #index" do
    context "with turbo_stream format" do
      it do
        get collab_annotation_comments_path(annotation), headers: turbo_stream_headers
        expect(response.body).to match("<turbo-stream action=\"update\"")
      end
    end
  end

  describe "GET #create" do
    context "with turbo_stream format" do
      let(:request) { post(collab_annotation_comments_path(annotation), params: params, headers: turbo_stream_headers) }

      context "when successful" do
        let(:params) { {comment: {message: "This is a comment"}} }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"replace\"")
            .and(not_match("<turbo-stream action=\"append\""))
            .and(match("<turbo-stream action=\"update\""))
        end
      end

      context "when failed" do
        let(:params) { {comment: {message: ""}} }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"replace\"")
            .and(not_match("<turbo-stream action=\"append\""))
            .and(match("<turbo-stream action=\"update\""))
          expect(response.body).to match("Message can&#39;t be blank")
        end
      end
    end
  end
end
