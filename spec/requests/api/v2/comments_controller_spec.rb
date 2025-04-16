# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::CommentsController) do
  let(:user) { create(:user) }
  let(:body) { JSON.parse(response.body) }
  let(:annotation) { create(:annotation, dish: build(:dish, user: user)) }

  before { api_sign_in(user) }

  describe "#index" do
    let!(:comment) { create(:comment, annotation: annotation) }

    it do
      get api_v2_annotation_comments_path(annotation, include: "annotation"), headers: auth_params
      expect(body["data"].count).to eq(1)
      expect(body["meta"]).to eq({"page" => 1, "prev" => nil, "next" => nil, "last" => 1})
    end
  end

  describe "#create" do
    let(:uuid) { SecureRandom.uuid }
    let(:params) {
      {
        data: {
          type: "comments",
          id: uuid,
          attributes: {
            message: "Hello World"
          }
        }
      }
    }

    context "when successful" do
      it do
        expect { post api_v2_annotation_comments_path(annotation, include: "annotation"), params: params.to_json, headers: auth_params }
          .to change(annotation.comments.reload, :count).by(1)
        json_data = body["data"]
        expect(json_data.keys).to contain_exactly("attributes", "id", "relationships", "type")
        expect(json_data["id"]).to eq(uuid)
        expect(json_data["attributes"]["message"]).to eq("Hello World")
        expect(body["included"].size).to eq(1)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Comment)
          .to receive(:valid?)
          .and_return(false)
        allow_any_instance_of(Comment)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(Comment.new).tap { |e| e.add(:message, "cannot be blank") })
      end

      it do
        post api_v2_annotation_comments_path(annotation), params: params.to_json, headers: auth_params
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {
                "detail" => "Message cannot be blank",
                "source" => {},
                "title" => "Invalid message"
              }
            ],
            "jsonapi" => {"version" => "1.0"}
          )
      end
    end
  end
end
