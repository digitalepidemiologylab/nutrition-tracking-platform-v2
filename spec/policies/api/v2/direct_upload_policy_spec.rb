# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::DirectUploadPolicy) do
  let(:user) { build(:user) }
  let(:policy) { described_class }

  permissions :create? do
    it { expect(policy).to permit(user, :direct_upload) }
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(user, :direct_upload).permitted_attributes)
        .to contain_exactly(
          :type,
          attributes: [
            :filename,
            :byte_size,
            :checksum,
            :content_type
          ]
        )
    end
  end
end
