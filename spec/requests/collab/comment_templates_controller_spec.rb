# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CommentTemplatesController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#index" do
    let!(:comment_template) { create(:comment_template, :valid) }

    it do
      get collab_comment_templates_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it do
      get new_collab_comment_template_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:request) { post collab_comment_templates_path, params: {comment_template: params} }

    context "with valid params" do
      let(:params) do
        {
          title_en: "title en",
          title_de: "title de",
          title_fr: "title fr",
          message_en: "message en",
          message_de: "message de",
          message_fr: "message fr"
        }
      end

      it do
        expect { request }
          .to change(CommentTemplate, :count).by(1)
        expect(response).to redirect_to(collab_comment_templates_path)
        expect(flash[:notice]).to eq("Comment template created successfully")
        expect(CommentTemplate.last.title).to eq("title en")
      end
    end

    context "with invalid params" do
      let(:params) { {title: ""} }

      it do
        expect { request }
          .not_to change(CommentTemplate, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#edit" do
    let(:comment_template) { create(:comment_template, :valid) }

    it do
      get edit_collab_comment_template_path(comment_template)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let!(:comment_template) { create(:comment_template, title_en: "title en", message_en: "message en") }
    let(:request) { put collab_comment_template_path(comment_template), params: {comment_template: params} }

    context "with valid params" do
      let(:params) { {title_en: "a_new_title"} }

      it do
        expect { request }
          .to change { comment_template.reload.title }.from("title en").to("a_new_title")
        expect(response).to redirect_to(collab_comment_templates_path)
        expect(flash[:notice]).to eq("Comment template updated successfully")
      end
    end

    context "with invalid params" do
      let(:params) { {title: "", title_en: ""} }

      it do
        expect { request }
          .not_to change { comment_template.reload.title }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#destroy" do
    let!(:comment_template) { create(:comment_template, :valid) }
    let(:request) { delete collab_comment_template_path(comment_template) }

    context "when successful" do
      it do
        expect { request }
          .to change(CommentTemplate, :count).by(-1)
        expect(response).to redirect_to(collab_comment_templates_path)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(CommentTemplate).to receive(:destroy).and_return(false)
      end

      it do
        expect { request }
          .not_to change(CommentTemplate, :count)
        expect(response).to redirect_to(collab_comment_templates_path)
        expect(flash[:alert]).to eq("Unable to delete the Comment template")
      end
    end
  end
end
