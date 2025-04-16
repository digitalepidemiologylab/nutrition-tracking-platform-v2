# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableComment) do
  let(:serialized) do
    # As we use `linkage always: true` in SerializableComment, we need to set the `_class` mannually.
    described_class.new(
      object: comment,
      _class: {
        Annotation: SerializableAnnotation,
        User: SerializableUser,
        Collaborator: SerializableCollaborator
      }
    ).as_jsonapi
  end

  context "when associated with user" do
    let(:comment) { create(:comment) }

    it do
      expect(serialized).to have_id(comment.id)
      expect(serialized)
        .to have_jsonapi_attributes(:message, :created_at).exactly
      expect(serialized).to have_attribute(:message).with_value(comment.message)
      expect(serialized[:relationships][:annotation][:data][:id]).to eq(comment.annotation_id)
      expect(serialized[:relationships][:collaborator][:data]).to be_nil
    end
  end

  context "when associated with collaborator" do
    let(:comment) { create(:comment, :from_collaborator) }

    it do
      expect(serialized).to have_id(comment.id)
      expect(serialized)
        .to have_jsonapi_attributes(:message, :created_at).exactly
      expect(serialized).to have_attribute(:message).with_value(comment.message)
      expect(serialized[:relationships][:annotation][:data][:id]).to eq(comment.annotation_id)
      expect(serialized[:relationships][:collaborator][:data][:id]).to eq(comment.collaborator_id)
    end
  end
end
