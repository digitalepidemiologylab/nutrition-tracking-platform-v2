# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableCollaborator) do
  let(:collaborator) { create(:collaborator) }
  let(:serialized) { described_class.new(object: collaborator).as_jsonapi }

  it do
    expect(serialized).to have_id(collaborator.id)
  end
end
