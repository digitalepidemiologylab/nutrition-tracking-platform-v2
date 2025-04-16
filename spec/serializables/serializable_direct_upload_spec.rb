# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableDirectUpload) do
  let(:direct_upload) { create(:direct_upload) }
  let(:serialized) { described_class.new(object: direct_upload).as_jsonapi }

  it do
    expect(serialized).to have_id(direct_upload.signed_id)
    expect(serialized).to have_jsonapi_attributes(:url, :headers).exactly
  end
end
